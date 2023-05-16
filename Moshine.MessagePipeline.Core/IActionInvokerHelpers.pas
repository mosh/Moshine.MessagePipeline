namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models, System.Threading;

type
  IActionInvokerHelpers = public interface
    method InvokeActionAsync(someAction:SavedAction; cancellationToken:CancellationToken := default):Task<Object>;
  end;

end.