namespace Moshine.MessagePipeline;

interface

uses
  System.Runtime.Serialization,
  System.Collections.Generic,
  System.Linq,
  System.Text;

type

  [KnownType(typeOf(DynamicDomainObject))]
  [DataContract]
  SavedAction = public class
  public
    constructor;
    [DataMember]
    property &Type:String;
    [DataMember]
    property &Method:String;
    [DataMember]
    property &Function:Boolean;
    [DataMember]
    property Id:Guid;
    [DataMember]
    property Parameters:List<Object>;
  end;

implementation

constructor SavedAction;
begin
  self.Id := Guid.NewGuid;
end;



end.
