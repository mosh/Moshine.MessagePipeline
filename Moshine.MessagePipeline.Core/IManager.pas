namespace Moshine.MessagePipeline.Core;

uses
   System.Threading;

type
  IManager = public interface
    method HasActionExecutedAsync(id:Guid; cancellationToken:CancellationToken := default):Task<Boolean>;
    method CompleteActionExecutionAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
  end;

end.