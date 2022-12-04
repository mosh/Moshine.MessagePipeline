namespace Moshine.MessagePipeline.Core;

type
  IScope = public interface(IDisposable)
    method CompleteAsync:Task;
  end;

end.