namespace Moshine.MessagePipeline.Core;

type
  IScope = public interface(IDisposable)
    method CompleteAsync(scopeId:Guid):Task;
  end;

end.