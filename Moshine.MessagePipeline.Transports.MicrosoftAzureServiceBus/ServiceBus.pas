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

    _topicName:String;
    _subscriptionName:String;
    _connectionString:String;


    _client:ServiceBusClient;
    _sender:ServiceBusSender;
    _receiver:ServiceBusReceiver;

  public

    constructor (connectionInformation:IServiceBusConnectionInformation; loggerImpl:ILogger);
    begin
      constructor(connectionInformation.ConnectionString, connectionInformation.TopicName, connectionInformation.SubscriptionName, loggerImpl);
    end;

    constructor(connectionString:String; topicName:String; subscriptionName:String; loggerImpl:ILogger);
    begin
      _topicName := topicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
      Logger := loggerImpl;
    end;

    method InitializeAsync(cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogTrace('Initialize');

      if(String.IsNullOrEmpty(_topicName))then
      begin
        var message := 'topicName has not been set';
        Logger.LogError(message);
        raise new ArgumentException(message);
      end;

      if(String.IsNullOrEmpty(_connectionString))then
      begin
        var message := 'connectionString has not been set';
        Logger.LogError(message);
        raise new ArgumentException(message);
      end;

      if(String.IsNullOrEmpty(_subscriptionName))then
      begin
        var message := 'subscriptionName has not been set';
        Logger.LogError(message);
        raise new ArgumentException(message);
      end;


      var client := new Azure.Messaging.ServiceBus.Administration.ServiceBusAdministrationClient(_connectionString);

      var response := await client.SubscriptionExistsAsync(_topicName, _subscriptionName,cancellationToken);

      if (not response.Value)then
      begin
        var message := $'Topic {_topicName} Subscription {_subscriptionName} does not exist';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;

      var subscriptionResponse := await client.GetSubscriptionAsync(_topicName, _subscriptionName, cancellationToken);

      var subscriptionProperties := subscriptionResponse.Value;

      Logger.LogInformation($'MaxDeliveryCount is {subscriptionProperties.MaxDeliveryCount} EnableDeadLetteringOnMessageExpiration {subscriptionProperties.DeadLetteringOnMessageExpiration}');

      if(not subscriptionProperties.DeadLetteringOnMessageExpiration)then
      begin
        var message := $'Topic {_topicName} Subscription {_subscriptionName} EnableDeadLetteringOnMessageExpiration must be enabled';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;


      _client := new ServiceBusClient(_connectionString);
      _sender := _client.CreateSender(_topicName);

      var options := new ServiceBusReceiverOptions();
      options.ReceiveMode := ServiceBusReceiveMode.PeekLock;

      _receiver := _client.CreateReceiver(_topicName, _subscriptionName, options);


    end;

    method SendAsync(message: IMessage; cancellationToken:CancellationToken := default): Task;
    begin

      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      Logger.LogTrace('Send');
      await _sender.SendMessageAsync(new Azure.Messaging.ServiceBus.ServiceBusMessage(internalMessage), cancellationToken);
      Logger.LogTrace('Sent');

    end;

    method SendAsync(messageContent: String; id: Guid; cancellationToken:CancellationToken := default): Task;
    begin

      var message := new Azure.Messaging.ServiceBus.ServiceBusMessage(messageContent);
      message.ApplicationProperties.Add(ServiceBusMessage.IdAttribute,id);
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