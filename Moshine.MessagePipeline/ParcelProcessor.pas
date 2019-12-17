namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Models,
  NLog, System.Threading.Tasks;

type

  ParcelProcessor = public class

  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;


    _actionSerializer:PipelineSerializer<SavedAction>;
    _cache:ICache;
    _actionInvokerHelpers:ActionInvokerHelpers;
    _bus:IBus;
    _scopeProvider:IScopeProvider;

    method LoadAsync(someAction:SavedAction):Task;
    begin
      Logger.Trace('Invoking action');

      var returnValue := await _actionInvokerHelpers.InvokeActionAsync(someAction);

      if(assigned(returnValue))then
      begin
        Logger.Trace('Setting value from invoked action');
        _cache.Add(someAction.Id.ToString,returnValue);
      end
      else
      begin
        Logger.Trace('No value returned from invoked action');
      end;

    end;


  public

    constructor(bus:IBus; actionSerializer:PipelineSerializer<SavedAction>;actionInvokerHelpers:ActionInvokerHelpers;
      cache:ICache; scopeProvider:IScopeProvider);
    begin
      _actionSerializer := actionSerializer;
      _actionInvokerHelpers := actionInvokerHelpers;
      _bus := bus;
      _cache := cache;
      _scopeProvider := scopeProvider;
    end;

    method ProcessMessageAsync(parcel:MessageParcel):Task;
    begin

      try

        var body := parcel.Message.GetBody;

        if(String.IsNullOrEmpty(body))then
        begin
          var message := 'Message body is empty';
          Logger.Debug(message);
          raise new ApplicationException(message);
        end
        else
        begin
          Logger.Trace('got body');
        end;

        var savedAction := _actionSerializer.Deserialize<SavedAction>(body);

        using scope := _scopeProvider.Provide do
        begin
          Logger.Trace('LoadAction');
          await LoadAsync(savedAction);
          Logger.Trace('Loaded Action');
          scope.Complete;
        end;

        parcel.State := MessageStateEnum.Processed;
        Logger.Trace('Processed message');
      except
        on E:Exception do
        begin
          var message := 'Failed to process message';
          Logger.Error(E,message);
          raise;
        end;

      end;

    end;

    method FaultedInProcessingAsync(parcel:MessageParcel):Task;
    begin
      Logger.Trace('FaultedInProcessing');

      using scope := _scopeProvider.Provide do
      begin

        await _bus.CannotBeProcessedAsync(parcel.Message);

        scope.Complete;
      end;

    end;

    method FinishProcessingAsync(parcel:MessageParcel):Task;
    begin
      Logger.Trace('Finish Processing');
      using scope := _scopeProvider.Provide do
      begin
        await parcel.Message.CompleteAsync;
        scope.Complete;
      end;

    end;

  end;

end.