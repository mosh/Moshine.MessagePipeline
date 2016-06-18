namespace TestHostConsoleApplication.Tests.Transport;

uses 
  RemObjects.Elements.EUnit, 
  Moshine.MessagePipeline,
  Moshine.MessagePipeline.Cache,
  Moshine.MessagePipeline.Transport, 
  TestHostConsoleApplication.Services;

type

  InMemoryTests = public class(Test)
  private

    _bus:IBus;
    _pipeline:IPipeline;
    _cache:ICache;

  public

    method SetupTest; override;
    begin
      _cache := new InMemoryCache;
      _bus := new InMemoryBus;
      _pipeline := new Pipeline(_cache,_bus);
      _pipeline.Start;
    end;

    method TeardownTest; override;
    begin
      _pipeline.Stop;
    end;

    /*
    method InvokeDisplayEmployee;
    begin
      ServiceExecuted.Init;
      var e:= new Employee(Id:=1,Name:='John Smith');
      _pipeline.Send<ServiceClass>(s -> s.DisplayEmployee(e));

      ServiceExecuted.Wait;

      Console.WriteLine('Done');

    end;
    */
    
    method InvokeSomeMethodWithParam;
    begin

      ServiceExecuted.Init;

      var obj:dynamic := new DynamicDomainObject;
      obj.Id := 1;
      obj.Title := 'John Smith';

      var obj2:Object := obj;	

      _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithParam(obj2));

      ServiceExecuted.Wait;

      Console.WriteLine('Done');

    end;
    

    method InvokeSomeMethod;
    begin
      ServiceExecuted.Init;

      _pipeline.Send<ServiceClass>(s -> s.SomeMethod);

      ServiceExecuted.Wait;

      Console.WriteLine('Done');
    end;

    method InvokeSomeMethodWithInteger;
    begin
      ServiceExecuted.Init;

      _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithInteger(4));

      ServiceExecuted.Wait;

      Console.WriteLine('Done');
    end;

  end;

end.
