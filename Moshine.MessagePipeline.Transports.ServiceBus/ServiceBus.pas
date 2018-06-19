namespace Moshine.MessagePipeline.Transports.ServiceBus;

uses
  Microsoft.Azure,
  Moshine.MessagePipeline.Core,
  Microsoft.ServiceBus,
  Microsoft.ServiceBus.Messaging;

type


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


    method Send(messageContent: String;id:String);
    begin
      var message := new BrokeredMessage(messageContent);
      message.Properties.Add('Id',id);
      message.Properties.Add('State','UnProcessed');

      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      topicClient.Send(message);

    end;

    method Send(message:IMessage);
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      topicClient.Send((message as ServiceBusMessage).InternalMessage);

    end;

    method Receive(serverWaitTime:TimeSpan):IMessage;
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_topic);
      var processingClient:= SubscriptionClient.CreateFromConnectionString(_connectionString, topicClient.Path, workSubscription,ReceiveMode.PeekLock);

      var someMessage := processingClient.Receive(serverWaitTime);

      exit iif(assigned(someMessage),new ServiceBusMessage(someMessage),nil);

    end;

    method CannotBeProcessed(message:IMessage);
    begin

      var clone := message.Clone;
      clone.AsError;
      self.Send(clone);
      message.Complete;
    end;


  end;

end.