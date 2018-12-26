namespace Moshine.MessagePipeline.Core;

type

  ICache = public interface
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

end.