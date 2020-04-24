namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  Microsoft.Extensions.Logging,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  Microsoft.Azure.ServiceBus.Management,
  Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.Models,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading.Tasks;

type

  ServiceBus = public class(IBus)
  private
    property Logger: ILogger;

    _topicName:String;
    _subscriptionName:String;
    _connectionString:String;
    _topicClient:TopicClient;
    _subscriptionReceiver:IMessageReceiver;
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

    method InitializeAsync:Task;
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
        Logger.LogError(nessage);
        raise new ArgumentException(message);
      end;

      var client := new ManagementClient(_connectionString);

      if (not await client.SubscriptionExistsAsync(_topicName,_subscriptionName)) then
      begin
        var message := $'Topic {_topicName} Subscription {_subscriptionName} does not exist';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;

      var subscription := await client.GetSubscriptionAsync(_topicName, _subscriptionName);

      Logger.LogInformation($'MaxDeliveryCount is {subscription.MaxDeliveryCount} EnableDeadLetteringOnMessageExpiration {subscription.EnableDeadLetteringOnMessageExpiration}');

      if(not subscription.EnableDeadLetteringOnMessageExpiration)then
      begin
        var message := $'Topic {_topicName} Subscription {_subscriptionName} EnableDeadLetteringOnMessageExpiration must be enabled';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;

      _topicClient := new TopicClient(_connectionString, _topicName);
      var subscriptionPath: String := EntityNameHelper.FormatSubscriptionPath(_topicName, _subscriptionName);
      _subscriptionReceiver := new MessageReceiver(_connectionString, subscriptionPath, ReceiveMode.PeekLock);

    end;

    method SendAsync(message: IMessage): Task;
    begin
      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      Logger.LogTrace('Send');
      await _topicClient.SendAsync(internalMessage);
      Logger.LogTrace('Sent');
    end;

    method SendAsync(messageContent: String; id: String): Task;
    begin
      var message := new Message(Encoding.UTF8.GetBytes(messageContent));
      message.UserProperties.Add('Id',id);
      Logger.LogTrace('Send');
      await _topicClient.SendAsync(message);
      Logger.LogTrace('Sent');
    end;

    method ReceiveAsync(serverWaitTime: TimeSpan): Task<IMessage>;
    begin
      var receivedMessage := await _subscriptionReceiver.ReceiveAsync(serverWaitTime);

      if(assigned(receivedMessage))then
      begin
        Logger.LogTrace('Received message');
        exit new ServiceBusMessage(_subscriptionReceiver, receivedMessage, Logger)
      end;
      exit nil;
    end;

    method CannotBeProcessedAsync(message: IMessage): Task;
    begin
      Logger.LogTrace('CannotBeProcessed');

      var clone := message.Clone;
      await clone.AsErrorAsync;

    end;

  end;
end.