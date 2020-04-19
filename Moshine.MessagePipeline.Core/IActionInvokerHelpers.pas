namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models;

type
  IActionInvokerHelpers = public interface
    method InvokeActionAsync(someAction:SavedAction):Task<Object>;
  end;

end.