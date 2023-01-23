namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models, System.Threading;

type

  ParcelReceiver = public class(IParcelReceiver)
  private
    parcelProcessor:IParcelProcessor;
  public
    constructor(parcelProcessImpl:IParcelProcessor);
    begin
      parcelProcessor := parcelProcessImpl;
    end;

    method ReceiveAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    begin

      try
        await parcelProcessor.ProcessMessageAsync(parcel, cancellationToken);
        await parcelProcessor.FinishProcessingAsync(parcel, cancellationToken);
      except
        on E:Exception do
        begin
          await parcelProcessor.FaultedInProcessingAsync(parcel);
          raise;
        end;
      end;

    end;
  end;

end.