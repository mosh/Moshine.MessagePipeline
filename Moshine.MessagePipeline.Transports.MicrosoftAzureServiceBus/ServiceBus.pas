namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  Azure.Messaging.ServiceBus,
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.Models,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading,
  System.Threading.Tasks;

type

  ServiceBus = public class(IBus)
  private
    property Logger: ILogger;

    _queueOrTopicName:String;
    _subscriptionName:String;
    _connectionString:String;


    _client:ServiceBusClient;
    _sender:ServiceBusSender;
    _receiver:ServiceBusReceiver;

    _afterCreated:Action<Azure.Messaging.ServiceBus.ServiceBusMessage>;

  public

    constructor (connectionInformation:IServiceBusConnectionInformation;
      afterCreated:Action<Azure.Messaging.ServiceBus.ServiceBusMessage> := default;
      loggerImpl:ILogger);
    begin
      constructor(connectionInformation.ConnectionString,
                  connectionInformation.TopicName,
                  connectionInformation.SubscriptionName,
                  afterCreated,
                  loggerImpl);
    end;

    constructor(connectionString:String; queueOrTopicName:String; subscriptionName:String;
      afterCreated:Action<Azure.Messaging.ServiceBus.ServiceBusMessage> := default;
      loggerImpl:ILogger);
    begin
      _queueOrTopicName := queueOrTopicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
      _afterCreated := afterCreated;
      Logger := loggerImpl;
    end;

    method InitializeAsync(cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogTrace('Initialize');

      if(String.IsNullOrEmpty(_queueOrTopicName))then
      begin
        var message := 'queueOrTopicName has not been set';
        Logger.LogError(message);
        raise new ArgumentException(message);
      end;

      if(String.IsNullOrEmpty(_connectionString))then
      begin
        var message := 'connectionString has not been set';
        Logger.LogError(message);
        raise new ArgumentException(message);
      end;

      var properties := ServiceBusConnectionStringProperties.Parse(_connectionString);

      if (_connectionString.IndexOf('UseDevelopmentEmulator=true',StringComparison.InvariantCultureIgnoreCase) = -1)then
      begin

        var client := new Azure.Messaging.ServiceBus.Administration.ServiceBusAdministrationClient(_connectionString);

        if(not String.IsNullOrEmpty(_subscriptionName))then
        begin
          var response := await client.SubscriptionExistsAsync(_queueOrTopicName, _subscriptionName,cancellationToken);

          if (not response.Value)then
          begin
            var message := $'Topic {_queueOrTopicName} Subscription {_subscriptionName} does not exist';
            Logger.LogError(message);
            raise new ApplicationException(message);
          end;

          var subscriptionResponse := await client.GetSubscriptionAsync(_queueOrTopicName, _subscriptionName, cancellationToken);

          var subscriptionProperties := subscriptionResponse.Value;

          Logger.LogInformation($'MaxDeliveryCount is {subscriptionProperties.MaxDeliveryCount} EnableDeadLetteringOnMessageExpiration {subscriptionProperties.DeadLetteringOnMessageExpiration}');

          if(not subscriptionProperties.DeadLetteringOnMessageExpiration)then
          begin
            var message := $'Topic {_queueOrTopicName} Subscription {_subscriptionName} EnableDeadLetteringOnMessageExpiration must be enabled';
            Logger.LogError(message);
            raise new ApplicationException(message);
          end;
        end;
      end
      else
      begin
        Logger.LogTrace('Using development emulator not verifying connection string');
      end;

      _client := new ServiceBusClient(_connectionString);
      _sender := _client.CreateSender(_queueOrTopicName);

      var options := new ServiceBusReceiverOptions;
      options.ReceiveMode := ServiceBusReceiveMode.PeekLock;

      if(String.IsNullOrEmpty(_subscriptionName)) then
      begin
        _receiver := _client.CreateReceiver(_queueOrTopicName, options);
      end
      else
      begin
        _receiver := _client.CreateReceiver(_queueOrTopicName, _subscriptionName, options);
      end;


    end;

    method SendAsync(message: IMessage; cancellationToken:CancellationToken := default): Task;
    begin

      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      Logger.LogTrace('Send');
      await _sender.SendMessageAsync(new Azure.Messaging.ServiceBus.ServiceBusMessage(internalMessage), cancellationToken);
      Logger.LogTrace('Sent');

    end;

    method SendAsync(messageContent: String; id: Guid;
      cancellationToken:CancellationToken := default): Task;
    begin

      var message := new Azure.Messaging.ServiceBus.ServiceBusMessage(messageContent);
      message.ApplicationProperties.Add(ServiceBusMessage.IdAttribute,id);

      if (_afterCreated <> default)then
      begin
        _afterCreated(message);
      end;

      Logger.LogTrace('Send');
      await _sender.SendMessageAsync(message, cancellationToken);
      Logger.LogTrace('Sent');

    end;

    method ReceiveAsync(serverWaitTime: TimeSpan; cancellationToken:CancellationToken := default): Task<IMessage>;
    begin

      var receivedMessage := await _receiver.ReceiveMessageAsync(serverWaitTime, cancellationToken);

      if(assigned(receivedMessage))then
      begin
        Logger.LogTrace('Received message');
        exit new ServiceBusMessage(_receiver, receivedMessage, Logger);

      end;
      exit nil;
    end;

  end;
end.