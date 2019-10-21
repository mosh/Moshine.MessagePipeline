﻿namespace Moshine.MessagePipeline.Core;

type

  ICache = public interface
    method &Add(key:String;value:Object);
    method Get<T>(key:String):T;
  end;

end.