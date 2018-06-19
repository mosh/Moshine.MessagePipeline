namespace Moshine.MessagePipeline.Core;

type

  IBus = public interface
    method Initialize;
    method Send(messageContent:String;id:String);
    method Send(message:IMessage);
    method Receive(serverWaitTime:TimeSpan):IMessage;
    method CannotBeProcessed(message:IMessage);

  end;

end.