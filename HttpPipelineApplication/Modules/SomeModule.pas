namespace HttpPipelineApplication.Modules;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  HttpPipelineApplication.Services,
  Moshine.MessagePipeline,
  Nancy;

type

  SomeModule = public class(NancyModule)
  private
    _pipeline:Pipeline;
  public
    constructor(pipeline:Pipeline);
  end;

implementation

constructor SomeModule(pipeline:Pipeline);
begin
  _pipeline := pipeline;

  Post['/Something'] := _ -> 
    begin 
      _pipeline.Send<SomeService>(s -> s.SomeMethod);

      exit Response.AsJson(new class());  
    end;

end;

end.
