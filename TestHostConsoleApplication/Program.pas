namespace TestHostConsoleApplication;

interface

uses
  System.Collections.Generic,
  System.Configuration,
  System.Dynamic,
  System.Linq, 
  System.Threading.Tasks,
  Microsoft.WindowsAzure, 
  RemObjects.Elements.EUnit,
  Moshine.MessagePipeline, 
  TestHostConsoleApplication.Tests;

type
  ConsoleApp = class
  public
    class method Main(args: array of String);
  end;


implementation


class method ConsoleApp.Main(args: array of String);
begin
//  var lTests := Discovery.DiscoverTests();
  var lTests := Discovery.FromType(typeOf(SerializerTests));
  Runner.RunTests(lTests) withListener(new ConsoleTestListener());

end;

end.
