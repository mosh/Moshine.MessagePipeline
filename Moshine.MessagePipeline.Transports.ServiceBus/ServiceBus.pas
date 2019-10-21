namespace Moshine.MessagePipeline.Transports.ServiceBus;

uses
  Microsoft.Azure,
  Moshine.MessagePipeline.Core,
  Microsoft.ServiceBus,
  Microsoft.ServiceBus.Messaging, System.Threading.Tasks;

type

  [Obsolete('Use Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.ServiceBus')]
  ServiceBus = public class(IBus)
  const
    workSubscription = 'work';
    errorSubscription = 'error';

  private
    _connectionString:String;
    _topic:String;

    _pipelineTopicDescription:TopicDescription;


  public
    constructor(appSettingKey:String; topic:String);
    begin
      _connectionString := CloudConfigurationManager.GetSetting(appSettingKey);
      _topic := topic;
    end;

    method Initialize;
    begin

      var namespaceManager := NamespaceManager.CreateFromConnectionString(_connectionString);

      if(not namespaceManager.TopicExists(_topic))then
      begin
        _pipelineTopicDescription:=namespaceManager.CreateTopic(_topic);
      end
      else
      begin
        _pipelineTopicDescription:= namespaceManager.GetTopic(_topic);
      end;

      if (not namespaceManager.SubscriptionExists(_pipelineTopicDescription.Path, workSubscription))then
      begin
        var workFilter := new SqlFilter("State = 'UnProcessed' ");
        namespaceManager.CreateSubscription(_pipelineTopicDescription.Path, workSubscription,workFilter);
      end;

      if (not namespaceManager.SubscriptionExists(_pipelineTopicDescription.Path, errorSubscription))then
      begin
        var errorFilter := new SqlFilter("State = 'Error' ");
        namespaceManager.CreateSubscription(_pipelineTopicDescription.Path, errorSubscription, errorFilter);
      end;


    end;


    method SendAsync(messageContent: String;id:String):Task;
    begin
      var message := new BrokeredMessage(messageContent);
      message.Properties.Add('Id',id);
      message.Properties.Add('State','UnProcessed');

      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      topicClient.Send(message);
      exit Task.CompletedTask;

    end;

    method SendAsync(message:IMessage):Task;
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      topicClient.Send((message as ServiceBusMessage).InternalMessage);
      exit Task.CompletedTask;
    end;

    method ReceiveAsync(serverWaitTime:TimeSpan):Task<IMessage>;
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      var processingClient:= SubscriptionClient.CreateFromConnectionString(_connectionString, topicClient.Path, workSubscription,ReceiveMode.PeekLock);

      var someMessage := processingClient.Receive(serverWaitTime);

      var receivedMessage:IMessage := iif(assigned(someMessage),new ServiceBusMessage(someMessage),nil);

      exit Task.FromResult(receivedMessage);

    end;

    method CannotBeProcessedAsync(message:IMessage):Task;
    begin

      var clone := message.Clone;
      clone.AsError;
      self.SendAsync(clone).Wait;
      message.Complete;
      exit Task.CompletedTask;
    end;


  end;

end.