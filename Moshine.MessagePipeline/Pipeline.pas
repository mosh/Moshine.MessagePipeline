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

  [Serializable]
  SavedAction = public class
  public
    property &Type:String;
    property &Method:String;
  end;

  Pipeline = public class
  private
    tokenSource:CancellationTokenSource;
    token:CancellationToken;
    processMessage:TransformBlock<BrokeredMessage, BrokeredMessage>;
    finishProcessing:ActionBlock<BrokeredMessage>;
    t:Task;

    _queue:String;
    _connectionString:String;

    method Setup;

    method Load(someAction:SavedAction);
    method EnQueue(someAction:SavedAction);

    method FindType(typeName:String):&Type;

    method Save<T>(methodCall: Expression<Action<T>>):SavedAction;


  public
    constructor(connectionString:String;queue:String);

    method Stop;
    method Start;

    method Send<T>(methodCall: System.Linq.Expressions.Expression<System.Action<T>>);
    method Send<T>(methodCall: System.Linq.Expressions.Expression<System.Action<T,dynamic>>);

  end;

implementation

constructor Pipeline(connectionString:String;queue:String);
begin
  _connectionString := connectionString;
  _queue:=queue;

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
      end);

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

method Pipeline.Send<T>(methodCall: System.Linq.Expressions.Expression<Action<T>>);
begin
  if(assigned(methodCall))then
  begin
    EnQueue(Save(methodCall));
  end;
end;

method Pipeline.Send<T>(methodCall: System.Linq.Expressions.Expression<System.Action<T,dynamic>>);
begin

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
  methodInfo.Invoke(obj,[]);
//  exit Delegate.CreateDelegate(someType,obj,methodInfo);
end;

method Pipeline.EnQueue(someAction: SavedAction);
begin
  var message := new BrokeredMessage(JsonConvert.SerializeObject(someAction));

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

