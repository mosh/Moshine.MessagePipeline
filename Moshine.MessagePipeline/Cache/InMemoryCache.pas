namespace Moshine.MessagePipeline.Cache;

uses
  NLog,
  System.Dynamic,
  System.Runtime.Caching,
  Moshine.MessagePipeline.Core,
  Newtonsoft.Json;

type

  InMemoryCache = public class(ICache)
  private
    _cache:ObjectCache;
    class property Logger: Logger := LogManager.GetCurrentClassLogger;
  public
    constructor;
    begin
       _cache := MemoryCache.Default;
    end;

    method Add(key:String;value:Object);
    begin
      Logger.Trace('Adding key');
      var policy := new CacheItemPolicy();
      policy.AbsoluteExpiration := DateTimeOffset.Now.AddHours(1);

      _cache.Add(key,JsonConvert.SerializeObject(value), policy);
    end;

    method Get(key:String):dynamic;
    begin
      Logger.Trace('Getting key');
      var obj:dynamic:=nil;

      var value := _cache.Get(key);
      if(assigned(value))then
      begin
        obj:=JsonConvert.DeserializeObject<ExpandoObject>(value.ToString);
      end;
      exit obj;
    end;

    method Get<T>(key:String):T;
    begin
      Logger.Trace('Getting key');
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