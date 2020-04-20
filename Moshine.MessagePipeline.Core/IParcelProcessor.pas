namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core.Models,
  System.Threading.Tasks;

type

  IParcelProcessor = public interface
    method ProcessMessageAsync(parcel:MessageParcel):Task;
    method FaultedInProcessingAsync(parcel:MessageParcel):Task;
    method FinishProcessingAsync(parcel:MessageParcel):Task;
  end;

end.