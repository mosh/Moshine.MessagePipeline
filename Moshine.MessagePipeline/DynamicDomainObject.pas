namespace Moshine.MessagePipeline;

interface

uses
  System.Collections,
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Runtime.Serialization,
  System.Text;

type

  [Serializable()]
  DynamicDomainObject = public class(DynamicObject, ISerializable,
  IDictionary<String, Object>,
  ICollection<KeyValuePair<String, Object>>,
  IEnumerable<KeyValuePair<String, Object>>,IEnumerable)
  private
    var     _values: Dictionary<String, Object> := new Dictionary<String, Object>(); readonly;implements IEnumerable, ICollection<KeyValuePair<String, Object>>,IEnumerable<KeyValuePair<String, Object>>,IDictionary<String, Object>;

  public
    method TrySetMember(binder: SetMemberBinder; value: Object): Boolean; override;
    method TryGetMember(binder: System.Dynamic.GetMemberBinder; out &result: System.Object): System.Boolean; override;
    method GetObjectData(info: SerializationInfo; context: StreamingContext);
    constructor(info:SerializationInfo;context:StreamingContext);
    constructor;
    constructor(someValues:Dictionary<String, Object>);
  end;


implementation

method DynamicDomainObject.TrySetMember(binder: SetMemberBinder; value: Object): Boolean;
begin
  _values[binder.Name] := value;
  exit true
end;

method DynamicDomainObject.GetObjectData(info: SerializationInfo; context: StreamingContext);
begin
  for each kvp in _values do 
  begin
    info.AddValue(kvp.Key, kvp.Value);
  end
end;

constructor DynamicDomainObject(info: SerializationInfo; context: StreamingContext);
begin

  for each entry in info do
  begin
    self._values.Add(entry.Name, entry.Value);
  end;
end;

constructor DynamicDomainObject;
begin

end;

method DynamicDomainObject.TryGetMember(binder: GetMemberBinder; out &result: Object): Boolean;
begin
  &result := _values[binder.Name];
  exit true;
end;

constructor DynamicDomainObject(someValues: Dictionary<String, Object>);
begin
  self._values := someValues;
end;



end.
