namespace Moshine.MessagePipeline.Cache.InMemory;

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

    method AddAsync(key:String;value:Object):Task;
    begin
      _cache.Set(key,JsonConvert.SerializeObject(value), DateTimeOffset.Now.AddHours(1));
      exit Task.CompletedTask;
    end;

    method GetAsync<T>(key:String): Task<tuple of (Boolean, T)>;
    begin
      var value : Object;
      if(_cache.TryGetValue(key, out value))then
      begin
        var foundValue := (true,JsonConvert.DeserializeObject<T>(value.ToString));
        exit Task.FromResult(foundValue);
      end;

      var missingValue := (false,default(T));

      exit Task.FromResult(missingValue);
    end;


  end;

end.