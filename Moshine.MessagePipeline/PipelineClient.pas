namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Collections.Generic,
  System.Linq,
  System.Linq.Expressions,
  System.Threading.Tasks;

type

  PipelineClient = public class(IPipelineClient)
  private
    property Logger: ILogger;

    _actionSerializer:PipelineSerializer<SavedAction>;
    _bus:IBus;
    _methodCallHelpers:MethodCallHelpers;
    cache:ICache;

    method EnQueue(someAction:SavedAction);
    begin
      Logger.LogTrace('Entering');
      var stringRepresentation := _actionSerializer.Serialize(someAction);
      Logger.LogTrace('SendAsync');
      _bus.SendAsync(stringRepresentation, someAction.Id.ToString).Wait;
      Logger.LogTrace('SentAsync');

    end;

    method EnQueueAsync(someAction:SavedAction):Task;
    begin
      Logger.LogTrace('Entering');
      var stringRepresentation := _actionSerializer.Serialize(someAction);
      Logger.LogTrace('SendAsync');
      await _bus.SendAsync(stringRepresentation, someAction.Id.ToString);
      Logger.LogTrace('SentAsync');

    end;

  public

    constructor(bus:IBus;cacheImpl:ICache; actionSerializerImpl:PipelineSerializer<SavedAction>; loggerImpl:ILogger);
    begin
      Logger := loggerImpl;
      _bus := bus;
      cache := cacheImpl;
      _methodCallHelpers := new MethodCallHelpers(Logger);
      _actionSerializer := actionSerializerImpl;
      Logger.LogTrace('Exiting');
    end;

    method InitializeAsync:Task;
    begin
      Logger.LogTrace('Initializing');
      await _bus.InitializeAsync;
      Logger.LogTrace('Initialized');
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    begin
      if(assigned(methodCall))then
      begin
        Logger.LogTrace('methodCall assigned');
        if(assigned(_methodCallHelpers))then
        begin
          Logger.LogTrace('methodCallHelpers assigned');
        end
        else
        begin
          Logger.LogTrace('methodCallHelpers not assigned');
        end;
        var saved := _methodCallHelpers.Save(methodCall);
        await EnQueueAsync(saved);
        var r := new Response(cache,Logger);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.LogTrace('methodCall not assigned');
      end;

    end;


    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        Logger.LogTrace('methodCall assigned');
        if(assigned(_methodCallHelpers))then
        begin
          Logger.LogTrace('_methodCallHelpers assigned');
        end
        else
        begin
          Logger.LogTrace('_methodCallHelpers not assigned');
        end;
        var saved := _methodCallHelpers.Save(methodCall);
        EnQueue(saved);
        var r := new Response(cache, Logger);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.LogTrace('methodCall not assigned');
      end;

    end;

    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    begin
      if(not assigned(methodCall))then
      begin
        Logger.LogTrace('methodCall not assigned');
        raise new ArgumentNullException('methodcall not assigned');
      end;

      var saved := _methodCallHelpers.Save(methodCall);
      await EnQueueAsync(saved);
      var r := new Response(cache, Logger);
      r.Id := saved.Id;
      exit r;
    end;


    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        Logger.LogTrace('methodCall not assigned');
        raise new ArgumentNullException('methodcall not assigned');
      end;

      var saved := _methodCallHelpers.Save(methodCall);
      EnQueue(saved);
      var r := new Response(cache, Logger);
      r.Id := saved.Id;
      exit r;

    end;

    method ReceiveAsync(serverWaitTime:TimeSpan):Task<MessageParcel>;
    begin
      var someMessage := await _bus.ReceiveAsync(serverWaitTime);

      if(assigned(someMessage))then
      begin
        exit new MessageParcel(Message := someMessage);
      end;
      exit nil;
    end;

    method CannotBeProcessedAsync(parcel:MessageParcel):Task;
    begin
      await _bus.CannotBeProcessedAsync(parcel.Message);

    end;



  end;
end.