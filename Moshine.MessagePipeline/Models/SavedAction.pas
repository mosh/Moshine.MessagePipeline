namespace Moshine.MessagePipeline;

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
    constructor;
    begin
      self.Id := Guid.NewGuid;
    end;

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