namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Linq.Expressions,
  System.Collections.Generic,
  System.Threading,
  System.Threading.Tasks;

type

  IPipelineClient = public interface

    method InitializeAsync:Task;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>; cancellationToken:CancellationToken := default):Task<Guid>;
    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>; cancellationToken:CancellationToken := default):Task<Guid>;

    method ReceiveAsync(serverWaitTime:TimeSpan; cancellationToken:CancellationToken := default):Task<MessageParcel>;


  end;
end.