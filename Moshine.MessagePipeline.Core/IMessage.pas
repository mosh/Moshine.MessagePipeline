namespace Moshine.MessagePipeline.Core;

type

  IMessage = public interface
    method Clone:IMessage;
    method GetBody:String;
    method AsError;
    method Complete;
  end;

end.