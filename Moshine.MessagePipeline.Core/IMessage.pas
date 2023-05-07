namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks, System.Threading;
type

  IMessage = public interface
    method Clone:IMessage;
    method GetBody:String;
    method AsErrorAsync(cancellationToken:CancellationToken := default):Task;
    method CompleteAsync(cancellationToken:CancellationToken := default):Task;
    property Id:Guid read;
  end;

end.