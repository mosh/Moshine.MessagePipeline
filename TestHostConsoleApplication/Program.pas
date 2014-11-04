namespace TestHostConsoleApplication;

interface

uses
  System.Collections.Generic,
  System.Configuration,
  System.Dynamic,
  System.Linq, 
  System.Threading.Tasks,
  Microsoft.WindowsAzure, 
  Moshine.MessagePipeline, 
  StackExchange.Redis;

type
  ConsoleApp = class
  public
    class method Main(args: array of String);
    class method PipelineTest(cache:ICache);
  end;

  ServiceClass = public class
  public
    method SomeMethod;
    method SomeOtherMethod:dynamic;
    method SomeMethodWithParam(param:Object);
    method SomeMethodWithInteger(param:Integer);
  end;

implementation

method ServiceClass.SomeMethod;
begin
  Console.WriteLine('Hello World');
end;

method ServiceClass.SomeOtherMethod: dynamic;
begin
  Console.WriteLine('SomeOtherMethod');
  var obj:dynamic := new ExpandoObject;
  obj.Id := 1;
  exit obj;
end;

method ServiceClass.SomeMethodWithParam(param:Object);
begin
  Console.WriteLine('SomeMethodWithParam');
  var obj := param as dynamic;
  Console.WriteLine(obj.Id);
  Console.WriteLine(obj.Title);
end;

method ServiceClass.SomeMethodWithInteger(param:Integer);
begin
  Console.WriteLine('SomeMethodWithInteger');
end;

class method ConsoleApp.Main(args: array of String);
begin
  //  var cacheString := ConfigurationManager.AppSettings['RedisCache'];
//  var cache := new RedisCache(ConnectionMultiplexer.Connect(cacheString));

//  var cache := new InMemoryCache;
//
//  PipelineTest(cache);

    var obj:dynamic := new DynamicDomainObject;
    obj.Id := 4;
    obj.Name := 'RedisCache';

    var action := new SavedAction;
    action.Id := Guid.NewGuid;
    action.Method:='SomeMethod';
    action.Parameters := new List<Object>;
    action.Parameters.Add(obj);

    var objAsString := PipelineSerializer.Serialize(action);

    var savedAction := PipelineSerializer.Deserialize<SavedAction>(objAsString);

end;

class method ConsoleApp.PipelineTest(cache:ICache);
begin
  var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');
  var pipeline := new Pipeline(connectionString,'pipeline',cache);


  pipeline.Start;
  try

    var obj:dynamic := new DynamicDomainObject;
    obj.Id := 1;
    obj.Title := 'John Smith';

    pipeline.Send<ServiceClass>(s -> s.SomeMethodWithInteger(4));
    var obj2:Object := obj;	
    pipeline.Send<ServiceClass>(s -> s.SomeMethodWithParam(obj2));
    pipeline.Send<ServiceClass>(s -> s.SomeMethod());

    Console.WriteLine('Press enter to quit.');
    Console.ReadLine();

  finally
    pipeline.Stop;
  end;

end;

end.
