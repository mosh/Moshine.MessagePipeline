namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  System.Collections.Generic,
  System.Linq,
  System.Text;

type

  MessageStateEnum = public enum(NotProcessed, Processed, Faulted);

  MessageParcel = public class
  private
  protected
  public
    property Message:IMessage;
    property State:MessageStateEnum;
    property ReTryCount:Integer;
  end;

end.
