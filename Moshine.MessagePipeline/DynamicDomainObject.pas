namespace Moshine.MessagePipeline;

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
    begin
      _values[binder.Name] := value;
      exit true
    end;

    method TryGetMember(binder: System.Dynamic.GetMemberBinder; out &result: System.Object): System.Boolean; override;
    begin
      &result := _values[binder.Name];
      exit true;
    end;

    method GetObjectData(info: SerializationInfo; context: StreamingContext);
    begin
      for each kvp in _values do 
      begin
        info.AddValue(kvp.Key, kvp.Value);
      end
    end;

    constructor(info:SerializationInfo;context:StreamingContext);
    begin
    
      for each entry in info do
      begin
        self._values.Add(entry.Name, entry.Value);
      end;
    end;

    constructor;
    begin
    
    end;

    constructor(someValues:Dictionary<String, Object>);
    begin
      self._values := someValues;
    end;

  end;

end.
