namespace Moshine.MessagePipeline.Core;

type

  ICache = public interface
    method &AddAsync(key:String;value:Object):Task;
    method GetAsync<T>(key:String):Task<tuple of (Boolean, T)>;
  end;

end.