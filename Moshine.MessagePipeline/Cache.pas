namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Text, 
  Newtonsoft.Json,
  StackExchange.Redis;

type

  Cache = public class
  private
    _connection:ConnectionMultiplexer;
  protected
  public
    constructor(connection:ConnectionMultiplexer);
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

implementation

method Cache.Add(key: String; value: Object);
begin
  var database := _connection.GetDatabase;
  var stringValue:= JsonConvert.SerializeObject(value);
  database.StringSet(key,stringValue);
end;

method Cache.Get(key: String): dynamic;
begin
  var obj:dynamic:=nil;
  var database := _connection.GetDatabase;
  var value:RedisValue:=database.StringGet(key);
  if(value.HasValue)then
  begin
    var stringValue:String := value;
    obj:=JsonConvert.DeserializeObject<ExpandoObject>(stringValue);
  end;
  exit obj;
end;

constructor Cache(connection: ConnectionMultiplexer);
begin
  _connection:=connection;
end;

end.
