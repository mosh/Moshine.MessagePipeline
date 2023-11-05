namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  System.Collections.Generic,
  System.Data,
  System.IO,
  System.Linq,
  System.Linq.Expressions,
  System.Reflection,
  System.Runtime.CompilerServices,
  System.Runtime.Serialization,
  System.Text,
  System.Threading,
  System.Threading.Tasks,
  System.Threading.Tasks.Dataflow,
  System.Transactions,
  System.Xml,
  System.Xml.Serialization,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models;

type

  Pipeline = public class(IPipeline)

  private

    property Logger: ILogger;

    _maxRetries:Integer;
    tokenSource:CancellationTokenSource;
    token:CancellationToken;
    processMessage:TransformBlock<MessageParcel, MessageParcel>;
    finishProcessing:ActionBlock<MessageParcel>;
    faultedInProcessing:ActionBlock<MessageParcel>;
    messageReceiveTask:Task;

    _client:IPipelineClient;
    _parcelProcessor:IParcelProcessor;

    method InitializeAsync:Task;
    begin
      Logger.LogInformation('Initializing Pipeline');

      await _client.InitializeAsync;

      SetupPipeline;

      Logger.LogInformation('Initialized Pipeline');
    end;


    method MessageReceiverAsync:Task;
    begin
      try
        Logger.LogInformation('Starting to receive messages');

        repeat
          var parcel := await _client.ReceiveAsync(ServerWaitTime, token);

          if(assigned(parcel))then
          begin
            Logger.LogInformation('Posting parcel');
            processMessage.Post(parcel);
            Logger.LogInformation('Posted parcel');
          end
          else
          begin
            Logger.LogInformation('No parcel to process');
          end;

        until token.IsCancellationRequested;
      except
        on tc:TaskCanceledException do
        begin
          Logger.LogInformation('Shutting down');
        end;
        on e:Exception do
        begin
          Logger.LogError(e,'Error receiving messages');
        end;
      end;

    end;

    method SetupPipeline;
    begin
      Logger.LogInformation('SetupPipeline');

      processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
          begin
            try
              Logger.LogInformation('Process Message');
              //await _parcelProcessor.ProcessMessageAsync(parcel, token);
              _parcelProcessor.ProcessMessageAsync(parcel, token).wait;
              Logger.LogInformation('Processed Message');
            except
              on e:Exception do
              begin
                Logger.LogError(e,'Exception in processMessage Block');
                parcel.State := MessageStateEnum.Faulted;
                parcel.ReTryCount := parcel.ReTryCount+1;
              end;
            end;

            exit parcel;
          end,
          new ExecutionDataflowBlockOptions(MaxDegreeOfParallelism := 5)
          );

      faultedInProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            try
              Logger.LogInformation('Faulting in processing');
              await _parcelProcessor.FaultedInProcessingAsync(parcel, token);
              Logger.LogInformation('Faulted in processing');
            except
              on e:Exception do
              begin
                Logger.LogError(e,'Exception in faultedInProcessing Block');
              end;
            end;
          end);

      finishProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            try
              Logger.LogInformation('Finishing processing');
              await _parcelProcessor.FinishProcessingAsync(parcel, token);
              Logger.LogInformation('Finished processing');
            except
              on e:Exception do
              begin
                Logger.LogError(e,'exception in finishProcessing block');
              end;
            end;
          end);

      processMessage.LinkTo(finishProcessing, p -> p.State = MessageStateEnum.Processed);
      processMessage.LinkTo(processMessage, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount < self._maxRetries));
      processMessage.LinkTo(faultedInProcessing, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount >= self._maxRetries));

    end;



  public

    property ServerWaitTime:TimeSpan := new TimeSpan(0,0,2);


    constructor(clientImpl:IPipelineClient; parcelProcessorImpl:IParcelProcessor; loggerImpl:ILogger);
    begin

      Logger := loggerImpl;
      _maxRetries := 4;

      tokenSource := new CancellationTokenSource;
      token := tokenSource.Token;

      _client := clientImpl;
      _parcelProcessor := parcelProcessorImpl;

      Logger.LogInformation('constructed');

    end;

    method StopAsync:Task;
    begin
      Logger.LogInformation('Stopping');
      tokenSource.Cancel;

      processMessage.Complete;

      Logger.LogInformation('Stopped processing messages');

      await processMessage.Completion.WaitAsync(TimeSpan.FromSeconds(30));

      Logger.LogInformation('Waiting to stop');
      await Task.WhenAll(messageReceiveTask);
      Logger.LogInformation('Stopped');

    end;


    method StartAsync:Task;
    begin
      Logger.LogInformation('Start');

      await InitializeAsync;

      messageReceiveTask := Task.Factory.StartNew( () -> MessageReceiverAsync, token);

    end;

    method Version:String;
    begin
      exit typeOf(Pipeline).Assembly.GetName.Version.ToString;
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<Guid>;
    begin
      exit await _client.SendAsync<T>(methodCall);
    end;

    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<Guid>;
    begin
      exit _client.SendAsync<T>(methodCall);
    end;

  end;

end.