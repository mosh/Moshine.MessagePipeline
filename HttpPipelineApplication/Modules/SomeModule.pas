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
  StackExchange.Redis;

type

  SomeModule = public class(NancyModule)
  private
    _pipeline:Pipeline;
    _cache:Cache;
  public
    constructor(pipeline:Pipeline;cache:Cache);
  end;

implementation

constructor SomeModule(pipeline:Pipeline;cache:Cache);
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
      exit Response.AsJson(obj);  
    end;

end;

end.
