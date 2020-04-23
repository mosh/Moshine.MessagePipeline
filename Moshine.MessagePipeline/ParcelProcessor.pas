namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Threading.Tasks;

type

  ParcelProcessor = public class(IParcelProcessor)

  private
    property Logger: ILogger;


    _actionSerializer:PipelineSerializer<SavedAction>;
    _cache:ICache;
    _actionInvokerHelpers:IActionInvokerHelpers;
    _client:IPipelineClient;
    _scopeProvider:IScopeProvider;

    method LoadAsync(someAction:SavedAction):Task;
    begin
      Logger.LogTrace('Invoking action');

      var returnValue := await _actionInvokerHelpers.InvokeActionAsync(someAction);

      if(assigned(returnValue))then
      begin
        Logger.LogTrace('Setting value from invoked action');
        _cache.Add(someAction.Id.ToString,returnValue);
      end
      else
      begin
        Logger.LogTrace('No value returned from invoked action');
      end;

    end;


  public

    constructor(clientImpl:IPipelineClient; actionSerializer:PipelineSerializer<SavedAction>;actionInvokerHelpers:IActionInvokerHelpers;
      cache:ICache; scopeProvider:IScopeProvider;loggerImpl:ILogger);
    begin
      _actionSerializer := actionSerializer;
      _actionInvokerHelpers := actionInvokerHelpers;
      _client := clientImpl;
      _cache := cache;
      _scopeProvider := scopeProvider;
      Logger := loggerImpl;
    end;

    method ProcessMessageAsync(parcel:MessageParcel):Task;
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
          Logger.LogTrace('Got body');
        end;

        var savedAction := _actionSerializer.Deserialize<SavedAction>(body);

        using scope := _scopeProvider.Provide do
        begin
          Logger.LogTrace('LoadAction');
          await LoadAsync(savedAction);
          Logger.LogTrace('Loaded Action');
          scope.Complete;
        end;

        parcel.State := MessageStateEnum.Processed;
        Logger.LogTrace('Processed message');
      except
        on E:Exception do
        begin
          var message := 'Failed to process message';
          Logger.LogError(E,message);
          raise;
        end;

      end;

    end;

    method FaultedInProcessingAsync(parcel:MessageParcel):Task;
    begin
      Logger.LogTrace('Faulting In Processing');

      using scope := _scopeProvider.Provide do
      begin
        await _client.CannotBeProcessedAsync(parcel);
        scope.Complete;
      end;
      Logger.LogTrace('Faulted In Processing');
    end;

    method FinishProcessingAsync(parcel:MessageParcel):Task;
    begin
      Logger.LogTrace('Finishing Processing');
      using scope := _scopeProvider.Provide do
      begin
        await parcel.Message.CompleteAsync;
        scope.Complete;
      end;
      Logger.LogTrace('Finished Processing');

    end;

  end;

end.