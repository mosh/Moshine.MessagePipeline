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

  DynamicDomainObjectIEnumerable = public class(IEnumerable)
  private
    var     _values: Dictionary<String, Object> := new Dictionary<String, Object>(); readonly;

    method GetEnumerator:IEnumerator ; 
  public
    constructor(values: Dictionary<String, Object>);
  end;


  [Serializable()]
  DynamicDomainObject = public class(DynamicObject, ISerializable,
  IDictionary<String, Object>,
  ICollection<KeyValuePair<String, Object>>,
  IEnumerable<KeyValuePair<String, Object>>)
  private
    var     _values: Dictionary<String, Object> := new Dictionary<String, Object>(); readonly;

    method get_Item(key: String): Object; 
    method set_Item(key: String; value: Object); 

    method get_Keys: System.Collections.Generic.ICollection<String>; 
    method get_Values: System.Collections.Generic.ICollection<Object>; 
    method ContainsKey(key: String): System.Boolean; 
    method &Add(key: String; value: Object); 
    method &Remove(key: String): System.Boolean; 
    method TryGetValue(key: String; out value: Object): System.Boolean; 

    property Item[key: String]: Object read get_Item write set_item; default; 
    property Keys: System.Collections.Generic.ICollection<String> read get_Keys; 
    property Values: System.Collections.Generic.ICollection<Object> read get_Values;

    method get_Count: System.Int32; 
    method get_IsReadOnly: System.Boolean; 
    method &Add(value: KeyValuePair<String, Object>); 
    method Clear;
    method Contains(value: KeyValuePair<String, Object>): System.Boolean; 
    method CopyTo(&array: array of KeyValuePair<String, Object>; arrayIndex: System.Int32); 
    method &Remove(value: KeyValuePair<String, Object>): System.Boolean; 
    property Count: System.Int32 read get_Count; 
    property IsReadOnly: System.Boolean read get_IsReadOnly; 

    method GetEnumerator:IEnumerator<KeyValuePair<String, Object>>; implements ICollection<KeyValuePair<String, Object>>.GetEnumerator;

    property DynamicDomainObjectEnumerable: DynamicDomainObjectIEnumerable; implements IEnumerable;
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
  DynamicDomainObjectEnumerable := new DynamicDomainObjectIEnumerable(_values);

  for each entry in info do
  begin
    self._values.Add(entry.Name, entry.Value);
  end;
end;

constructor DynamicDomainObject;
begin
  DynamicDomainObjectEnumerable := new DynamicDomainObjectIEnumerable(_values);

end;

method DynamicDomainObject.TryGetMember(binder: GetMemberBinder; out &result: Object): Boolean;
begin
  &result := _values[binder.Name];
  exit true;
end;

constructor DynamicDomainObject(someValues: Dictionary<String, Object>);
begin
  self._values := someValues;
  DynamicDomainObjectEnumerable := new DynamicDomainObjectIEnumerable(_values);
end;

method DynamicDomainObject.set_Item(key: String; value: Object);
begin
  _values.Item[key] := value;
end;

method DynamicDomainObject.get_Item(key: String): Object;
begin
  exit _values.Item[key];
end;

method DynamicDomainObject.get_Keys: ICollection<String>;
begin
  exit _values.Keys;
end;

method DynamicDomainObject.get_Values: ICollection<dynamic>;
begin
  exit _values.Values;
end;

method DynamicDomainObject.ContainsKey(key: String): Boolean;
begin
  exit _values.ContainsKey(key);
end;

method DynamicDomainObject.Add(key: String; value: Object);
begin

end;

method DynamicDomainObject.Remove(key: String): Boolean;
begin
  exit _values.Remove(key);
end;

method DynamicDomainObject.TryGetValue(key: String; out value: Object): Boolean;
begin
  exit _values.TryGetValue(key, out value);
end;

method DynamicDomainObject.get_Count: System.Int32; 
begin
  exit self._values.Count;
end;

method DynamicDomainObject.get_IsReadOnly: System.Boolean; 
begin
  exit false;
end;

method DynamicDomainObject.&Add(value: KeyValuePair<String, Object>); 
begin
  self._values.Add(value.Key, value.Value);
end;

method DynamicDomainObject.Clear;
begin
  self._values.Clear;
end;

method DynamicDomainObject.Contains(value: KeyValuePair<String, Object>): System.Boolean; 
begin
  exit self._values.Contains(value);
end;

method DynamicDomainObject.CopyTo(&array: array of KeyValuePair<String, Object>; arrayIndex: System.Int32); 
begin
  raise new NotImplementedException;
end;

method DynamicDomainObject.&Remove(value: KeyValuePair<String, Object>): System.Boolean; 
begin
  exit _values.Remove(value.Key);
end;

method DynamicDomainObjectIEnumerable.GetEnumerator: IEnumerator;
begin
  exit self._values.GetEnumerator;
end;

constructor DynamicDomainObjectIEnumerable(values: Dictionary<String, Object>);
begin
  values.ToList().ForEach(x -> self._values.Add(x.Key, x.Value));
end;

method DynamicDomainObject.GetEnumerator: IEnumerator< KeyValuePair<String, Object>>; 
begin
  exit _values.GetEnumerator;
end;


end.
