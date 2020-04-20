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
  Moshine.MessagePipeline.Cache,
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
    t:Task;

    _client:IPipelineClient;
    _parcelProcessor:IParcelProcessor;

    method InitializeAsync:Task;
    begin
      Logger.LogTrace('Initializing');

      await _client.InitializeAsync;

      SetupPipeline;

      Logger.LogTrace('Initialized');
    end;


    method MessageReceiver:Task;
    begin
      try
        Logger.LogTrace('Starting to receive');

        repeat
          var parcel := await _client.ReceiveAsync(ServerWaitTime);

          if(assigned(parcel))then
          begin
            Logger.LogTrace('Posting parcel');
            processMessage.Post(parcel);
          end;

        until token.IsCancellationRequested;
      except
        on e:Exception do
        begin
          Logger.LogError(e,'Error receiving messages');
          raise;
        end;
      end;

    end;

    method SetupPipeline;
    begin
      Logger.LogTrace('SetupPipeline');

      processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
          begin
            try
              Logger.LogTrace('ProcessMessage');
              await _parcelProcessor.ProcessMessageAsync(parcel);
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
            Logger.LogTrace('Fault in processing');
            try
              await _parcelProcessor.FaultedInProcessingAsync(parcel);

            except
              on e:Exception do
              begin
                Logger.LogError(e,'Exception in faultedInProcessing Block');
                raise;
              end;
            end;
          end);

      finishProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            try
              await _parcelProcessor.FinishProcessingAsync(parcel);
              Logger.LogTrace('Finished processing');
            except
              on e:Exception do
              begin
                Logger.LogError(e,'exception in finishProcessing block');
                raise;
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

      Logger.LogTrace('constructed');

    end;

    method StopAsync:Task;
    begin
      Logger.LogTrace('Token cancelled');
      tokenSource.Cancel;

      processMessage.Complete;

      Logger.LogTrace('Stopped processing messages');

      if(not finishProcessing.Completion.Wait(TimeSpan.FromSeconds(30))) then
      begin
        Logger.LogTrace('Timed out waiting after 30 seconds for finish processing messages');
      end
      else
      begin
        Logger.LogTrace('Stopped finish processing messages');
      end;

      Logger.LogTrace('Waiting to stop');
      await Task.WhenAll(t);
      Logger.LogTrace('Stopped');

    end;


    method StartAsync:Task;
    begin
      Logger.LogTrace('Start');

      await InitializeAsync;

      t := Task.Factory.StartNew( () -> MessageReceiver, token);

    end;

    method Version:String;
    begin
      exit typeOf(Pipeline).Assembly.GetName.Version.ToString;
    end;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    begin
      exit await _client.SendAsync<T>(methodCall);
    end;

    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    begin
      exit _client.Send<T>(methodCall);
    end;

    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    begin
      exit _client.SendAsync<T>(methodCall);
    end;

    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;
    begin
      exit _client.Send<T>(methodCall);
    end;

  end;

end.