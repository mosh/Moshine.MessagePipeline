namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
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
    _typeFinder:ITypeFinder;
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

    constructor(bus:IBus;cacheImpl:ICache; typeFinder:ITypeFinder; loggerImpl:ILogger);
    begin
      Logger := loggerImpl;
      _bus := bus;
      cache := cacheImpl;
      _methodCallHelpers := new MethodCallHelpers(Logger);
      _typeFinder := typeFinder;
      Logger.LogTrace('Exiting');
    end;

    method InitializeAsync:Task;
    begin
      Logger.LogTrace('Entering');
      await _bus.InitializeAsync;
      _actionSerializer := new PipelineSerializer<SavedAction>(_typeFinder.SerializationTypes.ToList);
      Logger.LogTrace('Exiting');
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
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
        await EnQueueAsync(saved);
        var r := new Response(cache);
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
        var r := new Response(cache);
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
      var r := new Response(cache);
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
      var r := new Response(cache);
      r.Id := saved.Id;
      exit r;

    end;

  end;
end.