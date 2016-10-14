namespace TestHostConsoleApplication.Tests.Transport;

uses 
  RemObjects.Elements.EUnit, 
  Moshine.MessagePipeline, 
  Moshine.MessagePipeline.Cache,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Transports.ServiceBus,
  TestHostConsoleApplication.Services;

type

  ServiceBusTests = public class(Test)
  private
    _bus:IBus;
    _pipeline:IPipeline;
    _cache:ICache;

  public
    method SetupTest; override;
    begin
      _cache := new InMemoryCache;
    
      _bus:= new ServiceBus('Microsoft.ServiceBus.ConnectionString','pipeline');
    
      _pipeline := new Pipeline(_cache,_bus);
      _pipeline.Start;
    end; 

    method TeardownTest; override;
    begin
      _pipeline.Stop;
    end; 


    method DomainObjectParameter();
    begin
      var obj:dynamic := new DynamicDomainObject;
      obj.Id := 1;
      obj.Title := 'John Smith';
    
      var obj2:Object := obj;	
      _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithParam(obj2));
    
    end;

    method IntegerParameterTest;
    begin
      _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithInteger(4));
    end;

    method NoParameter;
    begin
      _pipeline.Send<ServiceClass>(s -> s.SomeMethod());
    
    end;


  end;

end.
