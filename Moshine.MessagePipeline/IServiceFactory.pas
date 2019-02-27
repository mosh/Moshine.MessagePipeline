namespace Moshine.MessagePipeline;

type

  // Factory to create object of the types you want to call

  IServiceFactory = public interface
    method Create(someType:&Type):Object;
  end;

end.