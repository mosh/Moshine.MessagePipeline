namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models,
  system.Threading,
  System.Threading.Tasks;

type

  IParcelProcessor = public interface
    method ProcessMessageAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    method FaultedInProcessingAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    method FinishProcessingAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
  end;

end.