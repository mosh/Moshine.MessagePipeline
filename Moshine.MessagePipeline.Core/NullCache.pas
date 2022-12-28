namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core;

type
  NullCache = public class(ICache)
  public
    method AddAsync(key:String; value:Object):Task;
    begin
      exit Task.CompletedTask;
    end;

    method GetAsync<T>(key:String):Task<tuple of (Boolean, T)>;
    begin

      var value := (false,default(T));

      exit Task.FromResult(value);
    end;
  end;

end.