﻿namespace TestHostConsoleApplication;

uses
  System.Collections.Generic,
  System.Configuration,
  System.Dynamic,
  System.Linq, 
  System.Threading.Tasks,
  Microsoft.WindowsAzure, 
  RemObjects.Elements.EUnit,
  Moshine.MessagePipeline, 
  TestHostConsoleApplication.Tests, 
  TestHostConsoleApplication.Tests.Transport;

type
  ConsoleApp = class
  public
    class method Main(args: array of String);
    begin
    //  var lTests := Discovery.DiscoverTests();
      var lTests := Discovery.FromType(typeOf(ServiceBusTests));
      Runner.RunTests(lTests) withListener(new ConsoleTestListener());

      System.Console.ReadLine;
    end;
  end;

end.
