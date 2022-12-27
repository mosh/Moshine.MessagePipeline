namespace Moshine.MessagePipeline.Transports.BodyTransport;

uses
  Moshine.MessagePipeline.Core, Moshine.MessagePipeline.Core.Models;

type
  BodyMessageBuilder = public class(IBodyMessageBuilder)
  private
    _serializer:PipelineSerializer<SavedAction>;
  public
    constructor(serializer:PipelineSerializer<SavedAction>);
    begin
      _serializer := serializer;
    end;

    method Build(body:String):BodyMessage;
    begin
      var saved := _serializer.Deserialize<SavedAction>(body);
      exit new BodyMessage(body, saved.Id);
    end;
  end;

end.