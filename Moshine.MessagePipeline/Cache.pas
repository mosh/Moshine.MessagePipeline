namespace Moshine.MessagePipeline;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Runtime.Caching,
  System.Text, 
  Newtonsoft.Json,
  StackExchange.Redis;

type

  ICache = public interface
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

  InMemoryCache = public class(ICache)
  private
    _cache:ObjectCache;
  public
    constructor;
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

  RegionMemoryCache = public class(MemoryCache)
  public
    constructor;

    method &Set(item: CacheItem; policy: CacheItemPolicy); override;

    method &Set(key: String; value: Object; absoluteExpiration: DateTimeOffset; regionName: String := nil); override;

    method &Set(key: String; value: Object; policy: CacheItemPolicy; regionName: String := nil); override;

    method GetCacheItem(key: String; regionName: String := nil): CacheItem; override;

    method Get(key: String; regionName: String := nil): Object; override;

    property DefaultCacheCapabilities: DefaultCacheCapabilities read (inherited DefaultCacheCapabilities or System.Runtime.Caching.DefaultCacheCapabilities.CacheRegions); override;

  private
    method CreateKeyWithRegion(key: String; region: String): String;
  end;


  RedisCache = public class(ICache)
  private
    _connection:ConnectionMultiplexer;
  protected
  public
    constructor(connection:ConnectionMultiplexer);
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

implementation

method RedisCache.Add(key: String; value: Object);
begin
  var database := _connection.GetDatabase;
  var stringValue:= JsonConvert.SerializeObject(value);
  database.StringSet(key,stringValue);
end;

method RedisCache.Get(key: String): dynamic;
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

constructor RedisCache(connection: ConnectionMultiplexer);
begin
  _connection:=connection;
end;

constructor InMemoryCache;
begin
   _cache := MemoryCache.Default;
end;

method InMemoryCache.Add(key: String; value: Object);
begin
  var policy := new CacheItemPolicy();
  policy.AbsoluteExpiration := DateTimeOffset.Now.AddHours(1);

  _cache.Add(key,JsonConvert.SerializeObject(value), policy);
end;

method InMemoryCache.Get(key: String): dynamic;
begin
  var obj:dynamic:=nil;

  var value := _cache.Get(key);
  if(assigned(value))then
  begin
    obj:=JsonConvert.DeserializeObject<ExpandoObject>(value.ToString);
  end;
  exit obj;
end;

constructor RegionMemoryCache;
begin
  inherited constructor('defaultCustomCache');
end;

method RegionMemoryCache.&Set(item: CacheItem; policy: CacheItemPolicy);
begin
  &Set(item.Key, item.Value, policy, item.RegionName)
end;

method RegionMemoryCache.&Set(key: String; value: Object; absoluteExpiration: DateTimeOffset; regionName: String := nil);
begin
  &Set(key, value, new CacheItemPolicy( AbsoluteExpiration := absoluteExpiration), regionName)
end;

method RegionMemoryCache.&Set(key: String; value: Object; policy: CacheItemPolicy; regionName: String := nil);
begin
  inherited &Set(CreateKeyWithRegion(key, regionName), value, policy)
end;

method RegionMemoryCache.GetCacheItem(key: String; regionName: String := nil): CacheItem;
begin
  var temporary: CacheItem := inherited GetCacheItem(CreateKeyWithRegion(key, regionName));
  exit new CacheItem(key, temporary.Value, regionName)
end;

method RegionMemoryCache.Get(key: String; regionName: String := nil): Object;
begin
  exit inherited Get(CreateKeyWithRegion(key, regionName))
end;

method RegionMemoryCache.CreateKeyWithRegion(key: String; region: String): String;
begin
  exit 'region:' + (iif(region = nil, 'null_region', region)) + ';key=' + key
end;

end.
