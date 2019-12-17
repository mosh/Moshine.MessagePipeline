namespace Moshine.MessagePipeline.Core;

type
  ITypeFinder = public interface
    method FindServiceType(typeName:String):&Type;
    method SerializationTypes:sequence of &Type;
  end;

end.