namespace Moshine.MessagePipeline.Core;

type

  IMessage = public interface
    method Clone:IMessage;
    method GetBody:String;
    method AsError;
    method Complete;
  end;

  IBus = public interface
    method Initialize;
    method Send(messageContent:String;id:String);
    method Send(message:IMessage);
    method Receive(serverWaitTime:TimeSpan):IMessage;

  end;

end.
