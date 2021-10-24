namespace Moshine.MessagePipeline.Cache.Redis;

uses
  Moshine.MessagePipeline.Core,
  Newtonsoft.Json,
  StackExchange.Redis;

type
  RedisCache = public class(ICache)
  private
    property connectionMultiplexor:IConnectionMultiplexer;

  public
    constructor(connectionMultiplexorImpl:IConnectionMultiplexer);
    begin
      connectionMultiplexor := connectionMultiplexorImpl;

    end;

    method AddAsync(key:String;value:Object):Task;
    begin
      using db := connectionMultiplexor.GetDatabase do
      begin
        db.StringSet(key, JsonConvert.SerializeObject(value),new TimeSpan(0,0,30));
      end;

      exit Task.CompletedTask;
    end;

    method GetAsync<T>(key:String):Task<tuple of (Boolean, T)>;
    begin
      using db := connectionMultiplexor.GetDatabase do
      begin
        var value := await db.StringGetAsync(key);

        if(String.IsNullOrEmpty(value))then
        begin
          exit (false,default(T));
        end;

        exit (true,JsonConvert.DeserializeObject<T>(value));

      end;

    end;

  end;

end.