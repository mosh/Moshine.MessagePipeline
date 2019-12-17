namespace Moshine.MessagePipeline.Core;

type
  ITypeFinder = public interface
    method FindType(typeName:String):&Type;
  end;

end.