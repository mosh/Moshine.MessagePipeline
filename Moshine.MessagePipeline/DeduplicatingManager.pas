namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  System.Threading;

type
  DeduplicatingManager = public class(IManager)
  private
    _outboxRepository:IOutboxRepository;

  public
    constructor(outboxRepository:IOutboxRepository);
    begin
      _outboxRepository := outboxRepository;
    end;

    method HasActionExecutedAsync(id:Guid; cancellationToken:CancellationToken := default):Task<Boolean>;
    begin
      var row := await _outboxRepository.GetAsync(id, cancellationToken);
      if(not assigned(row))then
      begin
        exit false;
      end;
      exit true;
    end;

    method CompleteActionExecutionAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      await _outboxRepository.SetDispatchedAsync(id, cancellationToken);
    end;
  end;

end.