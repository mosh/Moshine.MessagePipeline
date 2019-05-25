namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Transactions;

type

  ParcelProcessor = public class

  private
    _actionSerializer:PipelineSerializer<SavedAction>;
    _cache:ICache;
    _actionInvokerHelpers:ActionInvokerHelpers;
    _logger:ILogger;
    _bus:IBus;

    method Load(someAction:SavedAction);
    begin
      _logger.Trace('Invoking action');

      var returnValue := _actionInvokerHelpers.InvokeAction(someAction);

      if(assigned(returnValue))then
      begin
        _cache.Add(someAction.Id.ToString,returnValue);
      end;

    end;


  public

    constructor(bus:IBus; actionSerializer:PipelineSerializer<SavedAction>;actionInvokerHelpers:ActionInvokerHelpers; cache:ICache; logger:ILogger);
    begin
      _actionSerializer := actionSerializer;
      _actionInvokerHelpers := actionInvokerHelpers;
      _bus := bus;
      _cache := cache;
      _logger := logger;
    end;

    method ProcessMessage(parcel:MessageParcel);
    begin

      var body := parcel.Message.GetBody;

      if(String.IsNullOrEmpty(body))then
      begin
        raise new ApplicationException('Message body is empty');
      end;

      var savedAction := _actionSerializer.Deserialize<SavedAction>(body);

      using scope := new TransactionScope(TransactionScopeOption.RequiresNew) do
      begin
        _logger.Trace('LoadAction');
        Load(savedAction);
        scope.Complete;
      end;

      parcel.State := MessageStateEnum.Processed;

    end;

    method FaultedInProcessing(parcel:MessageParcel);
    begin
      using scope := new TransactionScope do
      begin

        _bus.CannotBeProcessedAsync(parcel.Message).Wait;

        scope.Complete;
      end;

    end;

    method FinishProcessing(parcel:MessageParcel);
    begin
      parcel.Message.Complete;
    end;

  end;

end.