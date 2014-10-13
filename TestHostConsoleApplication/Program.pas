namespace TestHostConsoleApplication;

interface

uses
  System.Linq, 
  Microsoft.WindowsAzure, 
  Moshine.MessagePipeline;

type
  ConsoleApp = class
  public
    class method Main(args: array of String);
  end;

  ServiceClass = public class
  public
    method SomeMethod;
  end;

implementation

method ServiceClass.SomeMethod;
begin
  Console.WriteLine('Hello World');
end;

class method ConsoleApp.Main(args: array of String);
begin
  var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');

  var pipeline := new Pipeline(connectionString,'TestQueue');


  pipeline.Start;
  try

    pipeline.Send<ServiceClass>(s -> s.SomeMethod);

    Console.WriteLine('Press enter to quit.');
    Console.ReadLine();

  finally
    pipeline.Stop;
  end;
end;

end.
