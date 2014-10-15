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
  Microsoft.ServiceBus.Messaging, 
  Microsoft.WindowsAzure, 
  Newtonsoft.Json;

type


  Pipeline = public class(IPipeline)
  private
    tokenSource:CancellationTokenSource;
    token:CancellationToken;
    processMessage:TransformBlock<BrokeredMessage, BrokeredMessage>;
    finishProcessing:ActionBlock<BrokeredMessage>;
    t:Task;

    _queue:String;
    _connectionString:String;
    _cache:Cache;

    method Setup;

    method Load(someAction:SavedAction);
    method EnQueue(someAction:SavedAction);

    method FindType(typeName:String):&Type;

    method Save<T>(methodCall: Expression<Action<T>>):SavedAction;
    method Save<T>(methodCall: Expression<System.Func<T,Object>>):SavedAction;


  public
    constructor(connectionString:String;queue:String;cache:Cache);

    method Stop;
    method Start;

    method Send<T>(methodCall: Expression<System.Action<T>>):Response;
    method Send<T>(methodCall: Expression<System.Action<T,dynamic>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):Response;

  end;

implementation

constructor Pipeline(connectionString:String;queue:String;cache:Cache);
begin
  _connectionString := connectionString;
  _queue:=queue;
  _cache:=cache;

  tokenSource := new CancellationTokenSource();
  token := tokenSource.Token;

  Setup;
end;

method Pipeline.Setup;
begin
  processMessage := new TransformBlock<BrokeredMessage, BrokeredMessage>(message ->
      begin
        var body := message.GetBody<String>;
        var savedAction := JsonConvert.DeserializeObject<SavedAction>(body);
        using scope := new TransactionScope(TransactionScopeOption.RequiresNew) do
        begin
          Load(savedAction);
        end;
        exit message;
      end,
      new ExecutionDataflowBlockOptions(MaxDegreeOfParallelism := 5)
      );

  finishProcessing := new ActionBlock<BrokeredMessage>(message ->
      begin
        message.Complete;
      end);

  processMessage.LinkTo(finishProcessing);

  processMessage.Completion.ContinueWith(t ->
      begin
        if (t.IsFaulted) then
        begin
          IDataflowBlock(finishProcessing).Fault(t.Exception);
        end
         else finishProcessing.Complete();
      end);




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
  t := Task.Factory.StartNew( () -> 
    begin
      var client := QueueClient.CreateFromConnectionString(_connectionString, _queue);

      repeat
        var serverWaitTime := new TimeSpan(0,0,2);
        var someMessage := client.Receive(serverWaitTime);

        if(assigned(someMessage))then
        begin
          processMessage.Post(someMessage);
        end;

      until token.IsCancellationRequested;
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

  var client := QueueClient.CreateFromConnectionString(_connectionString, _queue);
  client.Send(message);

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


end.

