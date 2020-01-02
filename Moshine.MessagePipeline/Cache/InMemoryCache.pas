namespace Moshine.MessagePipeline.Cache;

uses
  Microsoft.Extensions.Caching.Memory,
  Moshine.MessagePipeline.Core,
  Newtonsoft.Json;

type

  InMemoryCache = public class(ICache)
  private
    _cache:IMemoryCache;
  public
    constructor;
    begin
        _cache := new MemoryCache(new MemoryCacheOptions ( ));
    end;

    method Add(key:String;value:Object);
    begin
      _cache.Set(key,JsonConvert.SerializeObject(value), DateTimeOffset.Now.AddHours(1));
    end;

    method Get<T>(key:String): tuple of (Boolean, T);
    begin
      var value : Object;
      if(_cache.TryGetValue(key, out value))then
      begin
        exit (true,JsonConvert.DeserializeObject<T>(value.ToString));
      end;
      exit (false,default(T));
    end;


  end;

end.
