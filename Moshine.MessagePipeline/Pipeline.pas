namespace Moshine.MessagePipeline;

uses
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
  Moshine.MessagePipeline.Models,
  NLog,
  Newtonsoft.Json;

type

  Pipeline = public class(IPipeline)

  private

    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    _actionSerializer:PipelineSerializer<SavedAction>;
    _maxRetries:Integer;
    tokenSource:CancellationTokenSource;
    token:CancellationToken;
    processMessage:TransformBlock<MessageParcel, MessageParcel>;
    finishProcessing:ActionBlock<MessageParcel>;
    faultedInProcessing:ActionBlock<MessageParcel>;
    t:Task;

    _cache:ICache;
    _bus:IBus;
    _typeFinder:ITypeFinder;

    _actionInvokerHelpers:ActionInvokerHelpers;
    _client:IPipelineClient;
    _parcelProcessor:ParcelProcessor;
    _scopeProvider:IScopeProvider;

    method MessageReceiver:Task;
    begin
      try
        Logger.Trace('Starting to receive');
        repeat

          var someMessage := await _bus.ReceiveAsync(ServerWaitTime);

          if(assigned(someMessage))then
          begin
            Logger.Trace('Posting message');
            var parcel := new MessageParcel(Message := someMessage);
            processMessage.Post(parcel);
          end;

        until token.IsCancellationRequested;
      except
        on e:Exception do
        begin
          Logger.Error(e,'Error receiving messages');
          raise;
        end;
      end;

    end;



    method InitializeAsync:Task;
    begin
      Logger.Trace('Initializing');
      await _bus.InitializeAsync;
      await _client.InitializeAsync(_typeFinder.SerializationTypes.ToList);

      _actionSerializer := new PipelineSerializer<SavedAction>(_typeFinder.SerializationTypes.ToList);
      _parcelProcessor := new ParcelProcessor(_bus,_actionSerializer,_actionInvokerHelpers, _cache, _scopeProvider);

      SetupPipeline;
      Logger.Trace('Initialized');
    end;

    method SetupPipeline;
    begin
      Logger.Trace('SetupPipeline');

      processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
          begin
            try
              Logger.Trace('ProcessMessage');
              await _parcelProcessor.ProcessMessageAsync(parcel);
            except
              on e:Exception do
              begin
                Logger.Error(e,'Exception in processMessage Block');
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
            Logger.Trace('Fault in processing');
            try
              await _parcelProcessor.FaultedInProcessingAsync(parcel);

            except
              on e:Exception do
              begin
                Logger.Error(e,'Exception in faultedInProcessing Block');
                raise;
              end;
            end;
          end);

      finishProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            try
              await _parcelProcessor.FinishProcessingAsync(parcel);
              Logger.Trace('Finished processing');
            except
              on e:Exception do
              begin
                Logger.Error(e,'exception in finishProcessing block');
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


    constructor(factory:IServiceFactory; cache:ICache; bus:IBus; scopeProvider:IScopeProvider;typeFinder:ITypeFinder);
    begin
      _maxRetries := 4;
      _cache:=cache;
      _bus:= bus;
      _scopeProvider := scopeProvider;
      _typeFinder := typeFinder;

      _actionInvokerHelpers := new ActionInvokerHelpers(factory, typeFinder);

      tokenSource := new CancellationTokenSource;
      token := tokenSource.Token;

      _client := new PipelineClient(bus, _cache);

      Logger.Trace('constructed');

    end;

    method Stop;
    begin
      Logger.Trace('Token cancelled');
      tokenSource.Cancel;

      processMessage.Complete;
      Logger.Trace('Stopped processing messages');
      if(not finishProcessing.Completion.Wait(new TimeSpan(0,0,0,30))) then
      begin
        Logger.Trace('Timed out waiting after 30 seconds for finish processing messages');
      end
      else
      begin
        Logger.Trace('Stopped finish processing messages');
      end;

      Logger.Trace('Waiting to stop');
      Task.WaitAll(t);
      Logger.Trace('Stopped');

    end;


    method Start;
    begin
      Logger.Trace('Start');

      t := Task.Factory.StartNew( () -> MessageReceiver, token);

    end;

    method Version:String;
    begin
      exit typeOf(Pipeline).Assembly.GetName.Version.ToString;
    end;

    method Send<T>(methodCall: Expression<Func<T,Boolean>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Double>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Integer>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,LongWord>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,ShortInt>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Single>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,SmallInt>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Word>>): IResponse;
    begin
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