namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Linq.Expressions,
  System.Runtime.CompilerServices,
  System.Text, 
  System.Threading,
  System.Threading.Tasks,
  System.Threading.Tasks.Dataflow, 
  System.Transactions,
  Microsoft.ServiceBus,
  Microsoft.ServiceBus.Messaging, 
  Microsoft.WindowsAzure, 
  Newtonsoft.Json;

type

  Pipeline = public class(IPipeline)
  const
    workSubscription = 'work';
    errorSubscription = 'error';

  private
    _maxRetries:Integer;
    tokenSource:CancellationTokenSource;
    token:CancellationToken;
    processMessage:TransformBlock<MessageParcel, MessageParcel>;
    finishProcessing:ActionBlock<MessageParcel>;
    faultedInProcessing:ActionBlock<MessageParcel>;
    t:Task;

    _name:String;
    _connectionString:String;
    _cache:Cache;

    _pipelineTopicDescription:TopicDescription;

    method Initialize;

    method Load(someAction:SavedAction);
    method EnQueue(someAction:SavedAction);

    method FindType(typeName:String):&Type;

    method Save<T>(methodCall: Expression<Action<T>>):SavedAction;
    method Save<T>(methodCall: Expression<System.Func<T,Object>>):SavedAction;

    method HandleTrace(message:String);
    method HandleException(e:Exception);

    method Setup;

  public
    constructor(connectionString:String;name:String;cache:Cache);

    method Stop;
    method Start;

    method Send<T>(methodCall: Expression<System.Action<T>>):Response;
    method Send<T>(methodCall: Expression<System.Action<T,dynamic>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):Response;

    property ErrorCallback:Action<Exception>;
    property TraceCallback:Action<String>;

  end;

implementation

constructor Pipeline(connectionString:String;name:String;cache:Cache);
begin
  _maxRetries := 5;
  _connectionString := connectionString;
  _name:=name;
  _cache:=cache;

  Initialize;

  tokenSource := new CancellationTokenSource();
  token := tokenSource.Token;

  Setup;
end;

method Pipeline.Setup;
begin
  processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
      begin
        try
          HandleTrace('ProcessMessage');
          var body := parcel.Message.GetBody<String>;
          var savedAction := JsonConvert.DeserializeObject<SavedAction>(body);
          using scope := new TransactionScope(TransactionScopeOption.RequiresNew) do
          begin
            HandleTrace('LoadAction');
            Load(savedAction);
          end;
          parcel.State := MessageStateEnum.Processed;
        except
          on E:Exception do
          begin
            HandleException(E);
            parcel.State := MessageStateEnum.Faulted;
            parcel.ReTryCount := parcel.ReTryCount+1;
          end;
        end;
        exit parcel;
      end,
      new ExecutionDataflowBlockOptions(MaxDegreeOfParallelism := 5)
      );

  faultedInProcessing := new ActionBlock<MessageParcel>(parcel ->
      begin
        HandleTrace('Fault in processing');
        try
          var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);

          using scope := new TransactionScope() do
          begin
            var copiedMessage := parcel.Message.Clone;
            copiedMessage.Properties.Remove('State');
            copiedMessage.Properties.Add('State','Error');
            topicClient.Send(copiedMessage);
            scope.Complete;
          end;

        except
          on e:Exception do
          begin
            HandleException(e);
            raise;
          end;
        end;
      end);

  finishProcessing := new ActionBlock<MessageParcel>(parcel ->
      begin
        HandleTrace('Finished processing');
        try
          parcel.Message.Complete;
        except
          on e:Exception do
          begin
            HandleException(e);
            raise;
          end;
        end;
      end);

  processMessage.LinkTo(finishProcessing, p -> p.State = MessageStateEnum.Processed);
  processMessage.LinkTo(processMessage, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount < self._maxRetries));
  processMessage.LinkTo(faultedInProcessing, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount >= self._maxRetries));
  
end;

method Pipeline.Stop;
begin
  processMessage.Complete();
  finishProcessing.Completion.Wait();

  tokenSource.Cancel();
  Task.WaitAll(t);

end;

method Pipeline.Start;
begin
  HandleTrace('Start');

  t := Task.Factory.StartNew( () -> 
    begin
      try
        var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);
        var processingClient:= SubscriptionClient.CreateFromConnectionString(_connectionString, topicClient.Path, workSubscription,ReceiveMode.PeekLock);

        repeat
          var serverWaitTime := new TimeSpan(0,0,2);
          var someMessage := processingClient.Receive(serverWaitTime);

          if(assigned(someMessage))then
          begin
            HandleTrace('Posting message');
            var parcel := new MessageParcel(Message := someMessage);
            processMessage.Post(parcel);
          end;

        until token.IsCancellationRequested;
      except
        on e:Exception do
        begin
          HandleException(e);
          raise;
        end;
      end;
    end, token);

end;

method Pipeline.Send<T>(methodCall: Expression<Action<T>>):Response;
begin
  if(assigned(methodCall))then
  begin
    var saved:=Save(methodCall);
    EnQueue(saved);
    exit new Response(Id:=saved.Id);
  end;
end;

method Pipeline.Send<T>(methodCall: Expression<System.Action<T,dynamic>>):Response;
begin
  raise new NotImplementedException;
end;

method Pipeline.Send<T>(methodCall: Expression<System.Func<T,Object>>):Response;
begin
  if(assigned(methodCall))then
  begin
    var saved := Save(methodCall);
    EnQueue(saved);
    exit new Response(Id:=saved.Id);
  end;

end;

method Pipeline.Save<T>(methodCall: Expression<System.Func<T,Object>>):SavedAction;
begin
  var expression := MethodCallExpression(methodCall.Body);

  var saved := new SavedAction;
  saved.&Type := expression.Method.DeclaringType.ToString; 
  saved.Method := expression.Method.Name;
  saved.Function:= true;
  exit saved;

end;


method Pipeline.Save<T>(methodCall: Expression<Action<T>>):SavedAction;
begin
  var expression := MethodCallExpression(methodCall.Body);

  var saved := new SavedAction;
  saved.&Type := expression.Method.DeclaringType.ToString; 
  saved.Method := expression.Method.Name;
  exit saved;
end;

method Pipeline.Load(someAction:SavedAction);
begin
  HandleTrace('Invoking action');

  var someType := FindType(someAction.&Type);

  var obj := Activator.CreateInstance(someType);
  var methodInfo := someType.GetMethod(someAction.&Method);
  if(someAction.Function)then
  begin
    var returnValue:= methodInfo.Invoke(obj,[]);
    _cache.Add(someAction.Id.ToString,returnValue);
  end
  else 
  begin
    methodInfo.Invoke(obj,[]);
  end;


//  exit Delegate.CreateDelegate(someType,obj,methodInfo);
end;

method Pipeline.EnQueue(someAction: SavedAction);
begin
  var message := new BrokeredMessage(JsonConvert.SerializeObject(someAction));
  message.Properties.Add('Id',someAction.Id.ToString);
  message.Properties.Add('State','UnProcessed');

  var topicClient := TopicClient.CreateFromConnectionString(_connectionString,_name);
  topicClient.Send(message);

end;


method Pipeline.FindType(typeName: String): &Type;
begin
  var types :=
            from a in AppDomain.CurrentDomain.GetAssemblies()
            from t in a.GetTypes()
            where t.FullName = typeName
            select t;
  exit types.FirstOrDefault;
end;

method Pipeline.HandleTrace(message:String);
begin
  if(assigned(self.TraceCallback))then
  begin
    self.TraceCallback(message);
  end;
end;

method Pipeline.HandleException(e:Exception);
begin
  if(assigned(self.ErrorCallback))then
  begin
    self.ErrorCallback(e);
  end;
end;

method Pipeline.Initialize;
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

//  if (not namespaceManager.SubscriptionExists(pipelineTopicDescription.Path, errorSubscription))then
//  begin
//    var errorFilter := new SqlFilter("State = 'Error' ");
//    errorSubscriptionDescription:=namespaceManager.CreateSubscription(pipelineTopicDescription.Path, errorSubscription, errorFilter);
//  end;


end.

