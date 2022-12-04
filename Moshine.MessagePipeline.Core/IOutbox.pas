namespace Moshine.MessagePipeline.Core;

type
  IOutbox = public interface
    method TryGet(id:Guid):Boolean;
    method Store(id:Guid);
    method SetDispatched(id:Guid);
  end;

end.