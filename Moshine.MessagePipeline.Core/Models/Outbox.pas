namespace Moshine.MessagePipeline.Core.Models;

type
  Outbox = public class
  private
  protected
  public
    property Id:Guid;
    property Dispatched:Boolean;
    property DispatchedAt:DateTimeOffset;
  end;

end.