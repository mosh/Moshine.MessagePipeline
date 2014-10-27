namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Runtime.Serialization,
  System.Text;

type

  [Serializable()]
  DynamicDomainObject = public class(DynamicObject, ISerializable)
  private
    var     values: Dictionary<String, Object> := new Dictionary<String, Object>(); readonly;
  public
    method TrySetMember(binder: SetMemberBinder; value: Object): Boolean; override;
    method TryGetMember(binder: System.Dynamic.GetMemberBinder; out &result: System.Object): System.Boolean; override;
    method GetObjectData(info: SerializationInfo; context: StreamingContext);
    constructor(info:SerializationInfo;context:StreamingContext);
    constructor;
  end;


implementation

method DynamicDomainObject.TrySetMember(binder: SetMemberBinder; value: Object): Boolean;
begin
  values[binder.Name] := value;
  exit true
end;

method DynamicDomainObject.GetObjectData(info: SerializationInfo; context: StreamingContext);
begin
  for each kvp in values do 
  begin
    info.AddValue(kvp.Key, kvp.Value);
  end
end;

constructor DynamicDomainObject(info: SerializationInfo; context: StreamingContext);
begin
  for each entry in info do
  begin
    self.values.Add(entry.Name, entry.Value);
  end;
end;

constructor DynamicDomainObject;
begin

end;

method DynamicDomainObject.TryGetMember(binder: GetMemberBinder; out &result: Object): Boolean;
begin
  &result := values[binder.Name];
  exit true;
end;


end.
