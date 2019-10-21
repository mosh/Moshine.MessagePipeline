namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IBus = public interface
    method Initialize;
    method SendAsync(messageContent:String;id:String):Task;
    method SendAsync(message:IMessage):Task;
    method ReceiveAsync(serverWaitTime:TimeSpan):Task<IMessage>;
    method CannotBeProcessedAsync(message:IMessage):Task;

  end;

end.