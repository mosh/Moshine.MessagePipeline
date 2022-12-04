namespace Moshine.MessagePipeline.Core;

type
  IOutbox = public interface
    method TryGetAsync(id:Guid):Task<Boolean>;
    method StoreAsync(id:Guid):Task;
    method SetDispatchedAsync(id:Guid):Task;
  end;

end.