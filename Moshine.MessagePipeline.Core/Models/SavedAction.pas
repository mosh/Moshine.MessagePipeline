namespace Moshine.MessagePipeline.Core.Models;

uses
  Moshine.MessagePipeline.Core,
  System.Runtime.Serialization,
  System.Collections.Generic,
  System.Linq,
  System.Text;

type

  [DataContract]
  SavedAction = public class
  public
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

end.