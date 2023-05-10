namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  System.Threading;

type

  DeduplicatingManager = public class(IManager)
  private
    _logger:ILogger;
    _outboxRepository:IOutboxRepository;

  public
    constructor(outboxRepository:IOutboxRepository; loggerImpl:ILogger<DeduplicatingManager>);
    begin
      _logger := loggerImpl;
      _outboxRepository := outboxRepository;
    end;

    method HasActionExecutedAsync(id:Guid; cancellationToken:CancellationToken := default):Task<Boolean>;
    begin
      try
        var row := await _outboxRepository.GetAsync(id, cancellationToken);
        if(not assigned(row))then
        begin
          exit false;
        end;
        exit true;
      except
        on e:Exception do
        begin
          _logger.LogError(e, 'HasActionExecutedAsync');
          raise;
        end;
      end;
    end;

    method CompleteActionExecutionAsync(id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      try
        await _outboxRepository.SetDispatchedAsync(id, cancellationToken);
      except
        on e:Exception do
        begin
          _logger.LogError(e, 'CompleteActionExecutionAsync');
          raise;
        end;
      end;
    end;
  end;

end.