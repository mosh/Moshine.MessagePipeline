namespace Moshine.MessagePipeline.Core;

type
  IManager = public interface
    method HasActionExecutedAsync(id:Guid):Task<Boolean>;
    method CompleteActionExecutionAsync(id:Guid):Task;
  end;

end.