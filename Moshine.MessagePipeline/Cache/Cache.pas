namespace Moshine.MessagePipeline.Cache;


uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Runtime.Caching,
  System.Text, 
  Newtonsoft.Json;

type

  ICache = public interface
    method Add(key:String;value:Object);
    method Get(key:String):dynamic;
  end;

end.
