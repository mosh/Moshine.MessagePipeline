namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IBus = public interface
    method InitializeAsync:Task;
    method SendAsync(messageContent:String;id:Guid):Task;
    method SendAsync(message:IMessage):Task;
    method ReceiveAsync(serverWaitTime:TimeSpan):Task<IMessage>;

  end;

end.