namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  Microsoft.ServiceBus.Messaging;

type

  MessageStateEnum = public enum(NotProcessed, Processed, Faulted);

  MessageParcel = public class
  private
  protected
  public
    property Message:BrokeredMessage;
    property State:MessageStateEnum;
    property ReTryCount:Integer;
  end;

implementation

end.
