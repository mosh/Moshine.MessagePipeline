namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models, system.Threading;

type

  IParcelReceiver = public interface
    method ReceiveAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
  end;

end.