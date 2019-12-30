﻿namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Linq.Expressions,
  System.Collections.Generic,
  System.Threading.Tasks;

type

  PipelineClient = public class(IPipelineClient)
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    _actionSerializer:PipelineSerializer<SavedAction>;
    _bus:IBus;
    _methodCallHelpers:MethodCallHelpers;
    cache:ICache;

    method EnQueue(someAction:SavedAction);
    begin
      Logger.Trace('Entering');
      var stringRepresentation := _actionSerializer.Serialize(someAction);
      Logger.Trace('SendAsync');
      _bus.SendAsync(stringRepresentation, someAction.Id.ToString).Wait;
      Logger.Trace('SentAsync');

    end;

    method EnQueueAsync(someAction:SavedAction):Task;
    begin
      Logger.Trace('Entering');
      var stringRepresentation := _actionSerializer.Serialize(someAction);
      Logger.Trace('SendAsync');
      await _bus.SendAsync(stringRepresentation, someAction.Id.ToString);
      Logger.Trace('SentAsync');

    end;

  public

    constructor(bus:IBus;cacheImpl:ICache);
    begin
      _bus := bus;
      cache := cacheImpl;
      _methodCallHelpers := new MethodCallHelpers;
      Logger.Trace('Exiting');
    end;

    method InitializeAsync(parameterTypes:List<&Type>):Task;
    begin
      Logger.Trace('Entering');
      await _bus.InitializeAsync;
      _actionSerializer := new PipelineSerializer<SavedAction>(parameterTypes);
      Logger.Trace('Exiting');
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    begin
      if(assigned(methodCall))then
      begin
        Logger.Trace('methodCall assigned');
        if(assigned(_methodCallHelpers))then
        begin
          Logger.Trace('_methodCallHelpers assigned');
        end
        else
        begin
          Logger.Trace('_methodCallHelpers not assigned');
        end;
        var saved := _methodCallHelpers.Save(methodCall);
        await EnQueueAsync(saved);
        var r := new Response(cache);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.Trace('methodCall not assigned');
      end;

    end;


    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        Logger.Trace('methodCall assigned');
        if(assigned(_methodCallHelpers))then
        begin
          Logger.Trace('_methodCallHelpers assigned');
        end
        else
        begin
          Logger.Trace('_methodCallHelpers not assigned');
        end;
        var saved := _methodCallHelpers.Save(methodCall);
        EnQueue(saved);
        var r := new Response(cache);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.Trace('methodCall not assigned');
      end;

    end;

    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    begin
      if(assigned(methodCall))then
      begin
        Logger.Trace('methodCall assigned');
        var saved := _methodCallHelpers.Save(methodCall);
        await EnQueueAsync(saved);
        var r := new Response(cache);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.Trace('methodCall not assigned');
      end;

    end;


    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        Logger.Trace('methodCall assigned');
        var saved := _methodCallHelpers.Save(methodCall);
        EnQueue(saved);
        var r := new Response(cache);
        r.Id := saved.Id;
        exit r;
      end
      else
      begin
        Logger.Trace('methodCall not assigned');
      end;

    end;

  end;
end.