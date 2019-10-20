namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
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

    method Load(someAction:SavedAction);
    begin
      Logger.Trace('Invoking action');

      var returnValue := _actionInvokerHelpers.InvokeAction(someAction);

      if(assigned(returnValue))then
      begin
        _cache.Add(someAction.Id.ToString,returnValue);
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

    method ProcessMessage(parcel:MessageParcel);
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
          Load(savedAction);
          Logger.Trace('Loaded Action');
          scope.Complete;
        end;

        parcel.State := MessageStateEnum.Processed;
      except
        on E:Exception do
        begin
          var message := 'Failed to process message';
          Logger.Error(E,message);
          raise;
        end;

      end;

    end;

    method FaultedInProcessing(parcel:MessageParcel):Task;
    begin
      Logger.Trace('FaultedInProcessing');

      using scope := _scopeProvider.Provide do
      begin

        await _bus.CannotBeProcessedAsync(parcel.Message);

        scope.Complete;
      end;

    end;

    method FinishProcessing(parcel:MessageParcel);
    begin
      Logger.Trace('FinishProcessing');
      parcel.Message.Complete;
    end;

  end;

end.