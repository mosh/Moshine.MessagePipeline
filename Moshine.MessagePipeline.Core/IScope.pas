namespace Moshine.MessagePipeline.Core;

uses
  System.Threading;

type
  IScope = public interface(IDisposable)
    method CompleteAsync(scopeId:Guid; cancellationToken:CancellationToken := default):Task;
  end;

end.