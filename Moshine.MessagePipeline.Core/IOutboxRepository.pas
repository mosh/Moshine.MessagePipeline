namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models;

type
  IOutbox = public interface
    method GetAsync(id:Guid):Task<Outbox>;
    method StoreAsync(id:Guid):Task;
    method SetDispatchedAsync(id:Guid):Task;
  end;

end.