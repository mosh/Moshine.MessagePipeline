namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core;

type
  DeduplicatingManager = public class(IManager)
  private
    _outboxRepository:IOutboxRepository;

  public
    constructor(outboxRepository:IOutboxRepository);
    begin
      _outboxRepository := outboxRepository;
    end;

    method HasActionExecutedAsync(id:Guid):Task<Boolean>;
    begin
      var row := await _outboxRepository.GetAsync(id);
      if(not assigned(row))then
      begin
        exit false;
      end;
      exit true;
    end;

    method CompleteActionExecutionAsync(id:Guid):Task;
    begin
      await _outboxRepository.SetDispatchedAsync(id);
    end;
  end;

end.