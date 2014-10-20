namespace TestHostConsoleApplication;

interface

uses
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
  end;

implementation

method ServiceClass.SomeMethod;
begin
  Console.WriteLine('Hello World');
end;

method ServiceClass.SomeOtherMethod: dynamic;
begin
  var obj:dynamic := new ExpandoObject;
  obj.Id := 1;
  exit obj;
end;

method ServiceClass.SomeMethodWithParam(param:Object);
begin

end;


class method ConsoleApp.Main(args: array of String);
begin
//  var cacheString := ConfigurationManager.AppSettings['RedisCache'];
//  var cache := new RedisCache(ConnectionMultiplexer.Connect(cacheString));

  var cache := new InMemoryCache;

  PipelineTest(cache);


end;

class method ConsoleApp.PipelineTest(cache:ICache);
begin
  var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');
  var pipeline := new Pipeline(connectionString,'pipeline',cache);


  pipeline.Start;
  try

    var obj:dynamic := new ExpandoObject;
    obj.Id := 1;

    pipeline.Send2<ServiceClass>(s -> s.SomeMethodWithParam(object(obj)));
    pipeline.Send<ServiceClass>(s -> s.SomeMethod());

    Console.WriteLine('Press enter to quit.');
    Console.ReadLine();

  finally
    pipeline.Stop;
  end;

end;

end.
