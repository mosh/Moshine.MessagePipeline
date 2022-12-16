namespace Moshine.MessagePipeline.Core;

uses
  System.Threading,
  System.Threading.Tasks;

type

  IBus = public interface
    method InitializeAsync:Task;
    method SendAsync(messageContent:String;id:Guid; cancellationToken:CancellationToken := default):Task;
    method SendAsync(message:IMessage; cancellationToken:CancellationToken := default):Task;
    method ReceiveAsync(serverWaitTime:TimeSpan; cancellationToken:CancellationToken := default):Task<IMessage>;

  end;

end.