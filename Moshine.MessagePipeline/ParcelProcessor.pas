namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Threading,
  System.Threading.Tasks;

type

  ParcelProcessor = public class(IParcelProcessor)

  private
    property Logger: ILogger;


    _actionSerializer:PipelineSerializer<SavedAction>;
    _cache:ICache;
    _actionInvokerHelpers:IActionInvokerHelpers;
    _scopeProvider:IScopeProvider;
    _manager:IManager;

    method LoadAsync(someAction:SavedAction; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('Invoking action');

      var returnValue := await _actionInvokerHelpers.InvokeActionAsync(someAction, cancellationToken);

      if(assigned(returnValue))then
      begin
        Logger.LogInformation('Setting value from invoked action');
        await _cache.AddAsync(someAction.Id.ToString,returnValue);
      end
      else
      begin
        Logger.LogInformation('No value returned from invoked action');
      end;

    end;


  public

    constructor(actionSerializer:PipelineSerializer<SavedAction>;actionInvokerHelpers:IActionInvokerHelpers;
      cache:ICache; scopeProvider:IScopeProvider; manager:IManager; loggerImpl:ILogger);
    begin
      _actionSerializer := actionSerializer;
      _actionInvokerHelpers := actionInvokerHelpers;
      _cache := cache;
      _scopeProvider := scopeProvider;
      Logger := loggerImpl;
      _manager := manager;
    end;

    method ProcessMessageAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    begin

      try

        var body := parcel.Message.GetBody;

        if(String.IsNullOrEmpty(body))then
        begin
          var message := 'Message body is empty';
          Logger.LogDebug(message);
          raise new ApplicationException(message);
        end
        else
        begin
          Logger.LogInformation('Got body');
        end;

        if (not await _manager.HasActionExecutedAsync(parcel.Message.Id, cancellationToken))then
        begin

          var savedAction:SavedAction := nil;
          try
            savedAction := _actionSerializer.Deserialize<SavedAction>(body);
          except
            on SE: System.Runtime.Serialization.SerializationException do
            begin
              var message := 'Failed to deserilize action';
              Logger.LogError(SE,$'{message} with body {body}');
              raise;
            end;
          end;


          using scope := _scopeProvider.Provide do
          begin
            Logger.LogInformation('LoadAction');
            await LoadAsync(savedAction);
            Logger.LogInformation('Loaded Action');
            await scope.CompleteAsync(parcel.Message.Id);
          end;
        end;

        parcel.State := MessageStateEnum.Processed;
        Logger.LogInformation('Processed message');
      except
        on E:Exception do
        begin
          var message := 'Failed to process message';
          Logger.LogError(E,message);
          raise;
        end;

      end;

    end;

    method FaultedInProcessingAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('Faulting In Processing');

      var clone := parcel.Message.Clone;
      await clone.AsErrorAsync;

      Logger.LogInformation('Faulted In Processing');
    end;

    method FinishProcessingAsync(parcel:MessageParcel; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('Finishing Processing');
      await _manager.CompleteActionExecutionAsync(parcel.Message.Id);
      await parcel.Message.CompleteAsync;
      Logger.LogInformation('Finished Processing');

    end;

  end;

end.