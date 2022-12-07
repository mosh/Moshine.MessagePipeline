namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core;

type
  SimpleManager = public class(IManager)
  public
    method HasActionExecutedAsync(id:Guid):Task<Boolean>;
    begin
      exit Task.FromResult(false);
    end;

    method CompleteActionExecutionAsync(id:Guid):Task;
    begin
      exit Task.CompletedTask;
    end;

  end;

end.