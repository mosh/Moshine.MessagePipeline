namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
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
  public
    constructor(connectionString:String; topicName:String; subscriptionName:String);
    begin
      _topicName := topicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
    end;

    method Initialize;
    begin
      _topicClient := new TopicClient(_connectionString, _topicName);
      _subscriptionClient := new SubscriptionClient(_connectionString, _topicName, _subscriptionName);
    end;

    method SendAsync(message: IMessage): Task;
    begin
      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      await _topicClient.SendAsync(internalMessage);
    end;

    method SendAsync(messageContent: String; id: String): Task;
    begin
      var message := new Message(Encoding.UTF8.GetBytes(messageContent));
      message.UserProperties.Add('Id',id);
      await _topicClient.SendAsync(message);
    end;

    method ReceiveAsync(serverWaitTime: TimeSpan): Task<IMessage>;
    begin
      var subscriptionPath: String := EntityNameHelper.FormatSubscriptionPath(_topicName, _subscriptionName);
      var subscriptionReceiver: IMessageReceiver := new MessageReceiver(_connectionString, subscriptionPath, ReceiveMode.ReceiveAndDelete);

      var receivedMessage := await subscriptionReceiver.ReceiveAsync(serverWaitTime);
      exit iif(assigned(receivedMessage),new ServiceBusMessage(subscriptionReceiver, receivedMessage),nil);

    end;

    method CannotBeProcessedAsync(message: IMessage): Task;
    begin
      var clone := message.Clone;
      clone.AsError;
      self.SendAsync(clone).Wait;
      message.Complete;
      exit Task.CompletedTask;

    end;

  end;
end.