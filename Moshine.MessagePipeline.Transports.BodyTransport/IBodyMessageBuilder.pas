namespace Moshine.MessagePipeline.Transports.BodyTransport;

type
  IBodyMessageBuilder = public interface
    method Build(body:String):BodyMessage;
  end;

end.