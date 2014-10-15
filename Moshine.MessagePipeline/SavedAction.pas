namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text;

type
  [Serializable]
  SavedAction = public class
  public
    constructor;
    property &Type:String;
    property &Method:String;
    property &Function:Boolean;
    property Id:Guid read write;
  end;

implementation

constructor SavedAction;
begin
  self.Id := Guid.NewGuid;
end;



end.
