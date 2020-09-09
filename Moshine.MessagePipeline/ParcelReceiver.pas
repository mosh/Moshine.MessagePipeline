namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models;

type

  ParcelReceiver = public class
  private
    parcelProcessor:IParcelProcessor;
  public
    constructor(parcelProcessImpl:IParcelProcessor);
    begin
      parcelProcessor := parcelProcessImpl;
    end;

    method Receive(parcel:MessageParcel):Task;
    begin

      try
        await parcelProcessor.ProcessMessageAsync(parcel);
        await parcelProcessor.FinishProcessingAsync(parcel);
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