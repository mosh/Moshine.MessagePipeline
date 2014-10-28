namespace HttpPipelineApplication.Modules;

interface

uses
  System.Collections.Generic,
  System.Configuration,
  System.Linq,
  System.Text, 
  HttpPipelineApplication.Services,
  Moshine.MessagePipeline,
  Nancy, 
  HttpPipelineApplication.Extensions,
  StackExchange.Redis;

type

  SomeModule = public class(NancyModule)
  private
    _pipeline:Pipeline;
    _cache:ICache;
  public
    constructor(pipeline:Pipeline;cache:ICache);
  end;

implementation

constructor SomeModule(pipeline:Pipeline;cache:ICache);
begin
  _pipeline := pipeline;
  _cache := cache;

  Post['/Something'] := _ -> 
    begin 
      _pipeline.Send<SomeService>(s -> s.SomeMethod);

      exit Response.AsJson(new class());  
    end;
  Put['/SomeObjectResponse'] := _ -> 
    begin 
      var pipelineResponse:=_pipeline.Send<SomeService>(s -> s.SomeMethodWithObject);
      var obj:Object:=pipelineResponse.WaitForResult(_cache);
      exit iif(assigned(obj), Response.AsJson(obj), HttpStatusCode.InternalServerError);
    end;

  Get['/CausesException'] := _ -> 
    begin 
      var pipelineResponse:=_pipeline.Send<SomeService>(s -> s.CausesException);
      var obj:Object:=pipelineResponse.WaitForResult(_cache);
      exit iif(assigned(obj), Response.AsJson(obj), HttpStatusCode.InternalServerError);
    end;
  Post['/SomeDomainObject'] := _ -> 
    begin 
      var obj2 := self.Request.Body.AsDomainObject as Object;

      _pipeline.Send<SomeService>(s -> s.SomeDomainObject(obj2));

      exit Response.AsJson(new class());  
    end;

end;

end.
