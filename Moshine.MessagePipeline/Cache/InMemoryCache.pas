namespace Moshine.MessagePipeline.Cache;

uses
  NLog,
  System.Dynamic,
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

    method Get<T>(key:String):T;
    begin
      var obj:T := nil;
      var value := _cache.Get(key);
      if(assigned(value))then
      begin
        obj:=JsonConvert.DeserializeObject<T>(value.ToString);
      end;
      exit obj;

    end;


  end;

end.