namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core, System.Threading;

type
  SimpleManager = public class(IManager)
  public
    method HasActionExecutedAsync(id:Guid; cancellationToken:CancellationToken := default):Task<Boolean>;
    begin
      exit Task.FromResult(false);
    end;

    method CompleteActionExecutionAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      exit Task.CompletedTask;
    end;

  end;

end.