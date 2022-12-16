namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models, System.Threading;

type
  IOutboxRepository = public interface
    method GetAsync(id:Guid; cancellationToken:CancellationToken := default):Task<Outbox>;
    method StoreAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
    method SetDispatchedAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
  end;

end.