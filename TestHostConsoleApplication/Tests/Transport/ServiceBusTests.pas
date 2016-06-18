namespace TestHostConsoleApplication.Tests.Transport;

uses 
  Microsoft.WindowsAzure,
  RemObjects.Elements.EUnit, 
  Moshine.MessagePipeline, 
  Moshine.MessagePipeline.Cache,
  Moshine.MessagePipeline.Transport,
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
      var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');
    
      _bus:= new ServiceBus(connectionString,'pipeline');
    
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
