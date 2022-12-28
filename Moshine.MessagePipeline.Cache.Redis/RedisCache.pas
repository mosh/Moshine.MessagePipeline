namespace Moshine.MessagePipeline.Cache.Redis;

uses
  Moshine.MessagePipeline.Core,
  StackExchange.Redis, System.Text.Json;

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
        db.StringSet(key, System.Text.Json.JsonSerializer.Serialize(value),new TimeSpan(0,0,30));
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

        exit (true,JsonSerializer.Deserialize<T>(value));

      end;

    end;

  end;

end.