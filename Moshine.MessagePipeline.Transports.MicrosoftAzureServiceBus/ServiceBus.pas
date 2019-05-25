namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  NLog,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading.Tasks;

type

  ServiceBus = public class(IBus)
  private
    _topicName:String;
    _subscriptionName:String;
    _connectionString:String;
    _topicClient:TopicClient;
    _subscriptionClient:SubscriptionClient;
    _subscriptionReceiver:IMessageReceiver;
    _logger:ILogger;
  public
    constructor(connectionString:String; topicName:String; subscriptionName:String; logger:ILogger);
    begin
      _topicName := topicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
      _logger := logger;
    end;

    method Initialize;
    begin
      _logger.Info('Initialize');
      _topicClient := new TopicClient(_connectionString, _topicName);
      _subscriptionClient := new SubscriptionClient(_connectionString, _topicName, _subscriptionName);
      var subscriptionPath: String := EntityNameHelper.FormatSubscriptionPath(_topicName, _subscriptionName);
      _subscriptionReceiver := new MessageReceiver(_connectionString, subscriptionPath, ReceiveMode.ReceiveAndDelete);

    end;

    method SendAsync(message: IMessage): Task;
    begin
      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      _logger.Info('Send');
      await _topicClient.SendAsync(internalMessage);
      _logger.Info('Sent');
    end;

    method SendAsync(messageContent: String; id: String): Task;
    begin
      var message := new Message(Encoding.UTF8.GetBytes(messageContent));
      message.UserProperties.Add('Id',id);
      _logger.Info('Send');
      await _topicClient.SendAsync(message);
      _logger.Info('Sent');
    end;

    method ReceiveAsync(serverWaitTime: TimeSpan): Task<IMessage>;
    begin
      _logger.Info('Receive');
      var receivedMessage := await _subscriptionReceiver.ReceiveAsync(serverWaitTime);

      if(assigned(receivedMessage))then
      begin
        _logger.Info('Received message');
        exit new ServiceBusMessage(_subscriptionReceiver, receivedMessage)
      end;
      _logger.Info('Received no message');
      exit nil;
    end;

    method CannotBeProcessedAsync(message: IMessage): Task;
    begin
      _logger.Info('CannotBeProcessed');

      var clone := message.Clone;
      clone.AsError;
      self.SendAsync(clone).Wait;
      message.Complete;
      exit Task.CompletedTask;

    end;

  end;
end.