namespace Moshine.MessagePipeline.Transport;

uses 
  Microsoft.ServiceBus,
  Microsoft.ServiceBus.Messaging;

type

  ServiceBusMessage = public class(IMessage)

  private
    method get_InternalMessage: BrokeredMessage;
    begin
      exit _message;
    end;
    _message:BrokeredMessage;

  public 
    constructor(message:BrokeredMessage);
    begin
      _message := message;
    end;

    property InternalMessage:BrokeredMessage read get_InternalMessage;

    method Clone: IMessage;
    begin
      exit new ServiceBusMessage(_message.Clone);
    end;

    method GetBody: String;
    begin
      exit _message.GetBody<String>;
    end;

    method AsError;
    begin
      _message.Properties.Remove('State');
      _message.Properties.Add('State','Error');
    end;

    method Complete;
    begin
      _message.Complete;
    end;

  end;

  ServiceBus = public class(IBus)
  const
    workSubscription = 'work';
    errorSubscription = 'error';

  private
    _connectionString:String;
    _name:String;

    _pipelineTopicDescription:TopicDescription;

  
  public
    constructor(connectionString:String; name:String);
    begin
      _connectionString := connectionString;
      _name:=name;
    end;

    method Initialize;
    begin

      var namespaceManager := NamespaceManager.CreateFromConnectionString(_connectionString);

      if(not namespaceManager.TopicExists(_name))then
      begin
        _pipelineTopicDescription:=namespaceManager.CreateTopic(_name);
      end
      else 
      begin
        _pipelineTopicDescription:= namespaceManager.GetTopic(_name)
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

      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);
      topicClient.Send(message);

    end;

    method Send(message:IMessage);
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);
      topicClient.Send((message as ServiceBusMessage).InternalMessage);

    end;

    method Receive(serverWaitTime:TimeSpan):IMessage;
    begin
      var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);
      var processingClient:= SubscriptionClient.CreateFromConnectionString(_connectionString, topicClient.Path, workSubscription,ReceiveMode.PeekLock);

      var someMessage := processingClient.Receive(serverWaitTime);

      exit iif(assigned(someMessage),new ServiceBusMessage(someMessage),nil);

    end;

  end;

end.
