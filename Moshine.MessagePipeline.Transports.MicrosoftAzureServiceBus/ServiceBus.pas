namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  NLog,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  Microsoft.Azure.ServiceBus.Management,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading.Tasks;

type

  ServiceBus = public class(IBus)
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    _topicName:String;
    _subscriptionName:String;
    _connectionString:String;
    _topicClient:TopicClient;
    _subscriptionReceiver:IMessageReceiver;
  public
    constructor(connectionString:String; topicName:String; subscriptionName:String);
    begin
      _topicName := topicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
    end;

    method InitializeAsync:Task;
    begin
      Logger.Info('Initialize');

      if(String.IsNullOrEmpty(_topicName))then
      begin
        raise new ArgumentException('topicName has not been set');
      end;

      if(String.IsNullOrEmpty(_connectionString))then
      begin
        raise new ArgumentException('connectionString has not been set');
      end;

      if(String.IsNullOrEmpty(_subscriptionName))then
      begin
        raise new ArgumentException('subscriptionName has not been set');
      end;

      var client := new ManagementClient(_connectionString);

      if (not await client.SubscriptionExistsAsync(_topicName,_subscriptionName)) then
      begin
        raise new ApplicationException($'Topic {_topicName} Subscription {_subscriptionName} does not exist');
      end;

      var subscription := await client.GetSubscriptionAsync(_topicName, _subscriptionName);

      Logger.Info($'MaxDeliveryCount is {subscription.MaxDeliveryCount} EnableDeadLetteringOnMessageExpiration {subscription.EnableDeadLetteringOnMessageExpiration}');

      if(not subscription.EnableDeadLetteringOnMessageExpiration)then
      begin
        raise new ApplicationException($'Topic {_topicName} Subscription {_subscriptionName} EnableDeadLetteringOnMessageExpiration must be enabled');
      end;

      _topicClient := new TopicClient(_connectionString, _topicName);
      var subscriptionPath: String := EntityNameHelper.FormatSubscriptionPath(_topicName, _subscriptionName);
      _subscriptionReceiver := new MessageReceiver(_connectionString, subscriptionPath, ReceiveMode.PeekLock);

    end;

    method SendAsync(message: IMessage): Task;
    begin
      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      Logger.Info('Send');
      await _topicClient.SendAsync(internalMessage);
      Logger.Info('Sent');
    end;

    method SendAsync(messageContent: String; id: String): Task;
    begin
      var message := new Message(Encoding.UTF8.GetBytes(messageContent));
      message.UserProperties.Add('Id',id);
      Logger.Info('Send');
      await _topicClient.SendAsync(message);
      Logger.Info('Sent');
    end;

    method ReceiveAsync(serverWaitTime: TimeSpan): Task<IMessage>;
    begin
      var receivedMessage := await _subscriptionReceiver.ReceiveAsync(serverWaitTime);

      if(assigned(receivedMessage))then
      begin
        Logger.Info('Received message');
        exit new ServiceBusMessage(_subscriptionReceiver, receivedMessage)
      end;
      exit nil;
    end;

    method CannotBeProcessedAsync(message: IMessage): Task;
    begin
      Logger.Info('CannotBeProcessed');

      var clone := message.Clone;
      await clone.AsErrorAsync;

    end;

  end;
end.