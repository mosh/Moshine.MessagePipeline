namespace Moshine.MessagePipeline.Cache;

uses
  System.Dynamic,
  System.Runtime.Caching,
  Moshine.MessagePipeline.Core,
  Newtonsoft.Json;

type

  InMemoryCache = public class(ICache)
  private
    _cache:ObjectCache;
  public
    constructor;
    begin
       _cache := MemoryCache.Default;
    end;

    method Add(key:String;value:Object);
    begin
      var policy := new CacheItemPolicy();
      policy.AbsoluteExpiration := DateTimeOffset.Now.AddHours(1);

      _cache.Add(key,JsonConvert.SerializeObject(value), policy);
    end;

    method Get(key:String):dynamic;
    begin
      var obj:dynamic:=nil;

      var value := _cache.Get(key);
      if(assigned(value))then
      begin
        obj:=JsonConvert.DeserializeObject<ExpandoObject>(value.ToString);
      end;
      exit obj;
    end;

  end;

end.