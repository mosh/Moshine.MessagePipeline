namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Collections.Generic,
  System.Linq,
  System.Linq.Expressions,
  System.Threading,
  System.Threading.Tasks;

type

  PipelineClient = public class(IPipelineClient)
  private
    property Logger: ILogger;

    _actionSerializer:PipelineSerializer<SavedAction>;
    _bus:IBus;
    _methodCallHelpers:MethodCallHelpers;

    method EnQueueAsync(someAction:SavedAction; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('Starting EnQueueAsync');
      var stringRepresentation := _actionSerializer.Serialize(someAction);
      Logger.LogInformation('EnQueueAsync SendAsync');
      await _bus.SendAsync(stringRepresentation, someAction.Id, cancellationToken);
      Logger.LogInformation('EnQueueAsync SentAsync');

    end;

  public

    constructor(bus:IBus; actionSerializerImpl:PipelineSerializer<SavedAction>; loggerImpl:ILogger);
    begin
      Logger := loggerImpl;
      _bus := bus;
      _methodCallHelpers := new MethodCallHelpers(Logger);
      _actionSerializer := actionSerializerImpl;
    end;

    method InitializeAsync:Task;
    begin
      Logger.LogInformation('Initializing');
      await _bus.InitializeAsync;
      Logger.LogInformation('Initialized');
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>; cancellationToken:CancellationToken := default):Task<Guid>;
    begin
      if(assigned(methodCall))then
      begin
        Logger.LogInformation('methodCall assigned');
        if(assigned(_methodCallHelpers))then
        begin
          Logger.LogInformation('methodCallHelpers assigned');
        end
        else
        begin
          Logger.LogInformation('methodCallHelpers not assigned');
        end;
        var saved := _methodCallHelpers.Save(methodCall);
        await EnQueueAsync(saved, cancellationToken);
        exit saved.Id;
      end
      else
      begin
        Logger.LogInformation('methodCall not assigned');
      end;

    end;

    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>; cancellationToken:CancellationToken := default):Task<Guid>;
    begin
      if(not assigned(methodCall))then
      begin
        Logger.LogInformation('methodCall not assigned');
        raise new ArgumentNullException('methodcall not assigned');
      end;

      var saved := _methodCallHelpers.Save(methodCall);
      await EnQueueAsync(saved, cancellationToken);
      exit saved.Id;
    end;

    method ReceiveAsync(serverWaitTime:TimeSpan; cancellationToken:CancellationToken := default):Task<MessageParcel>;
    begin
      var someMessage := await _bus.ReceiveAsync(serverWaitTime, cancellationToken);

      if(assigned(someMessage))then
      begin
        exit new MessageParcel(Message := someMessage);
      end;
      exit nil;
    end;

  end;
end.