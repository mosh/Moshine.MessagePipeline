namespace Moshine.MessagePipeline.Core;

type
  IScope = public interface(IDisposable)
    method Complete;
  end;

end.