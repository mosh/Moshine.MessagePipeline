namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models;

type

  IParcelReceiver = public interface
    method ReceiveAsync(parcel:MessageParcel):Task;
  end;

end.