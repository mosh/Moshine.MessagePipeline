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
  NLog,
  Newtonsoft.Json;

type

  Pipeline = public class(IPipeline)
  const
    workSubscription = 'work';
    errorSubscription = 'error';

  private
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

    _actionInvokerHelpers:ActionInvokerHelpers;
    _client:IPipelineClient;
    _parcelProcessor:ParcelProcessor;

    _logger:ILogger;


    method Initialize(parameterTypes:List<&Type>);
    begin
      _bus.Initialize;

      _actionSerializer := new PipelineSerializer<SavedAction>(parameterTypes);
      _parcelProcessor := new ParcelProcessor(_bus,_actionSerializer,_actionInvokerHelpers, _cache,_logger);

      SetupPipeline;
    end;

    method SetupPipeline;
    begin
      _logger.Trace('SetupPipeline');

      processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
          begin
            try
              _logger.Trace('ProcessMessage');
              _parcelProcessor.ProcessMessage(parcel);
            except
              on e:Exception do
              begin
                _logger.Error(e,'processMessage Block');
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
            _logger.Trace('Fault in processing');
            try
              _parcelProcessor.FaultedInProcessing(parcel);

            except
              on e:Exception do
              begin
                _logger.Error(e,'faultedInProcessing Block');
                raise;
              end;
            end;
          end);

      finishProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            _logger.Trace('Finished processing');
            try
              _parcelProcessor.FinishProcessing(parcel);
            except
              on e:Exception do
              begin
                _logger.Error(e,'finishProcessing block');
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


    constructor(factory:IServiceFactory; cache:ICache;bus:IBus;logger:ILogger);
    begin
      _maxRetries := 4;
      _cache:=cache;
      _bus:= bus;

      _actionInvokerHelpers := new ActionInvokerHelpers(factory);

      tokenSource := new CancellationTokenSource();
      token := tokenSource.Token;

      _client := new PipelineClient(bus);
      _logger := logger;

    end;

    method Stop;
    begin
      _logger.Trace('Token cancelled');
      tokenSource.Cancel;

      processMessage.Complete();
      _logger.Trace('Stopped processing messages');
      if(not finishProcessing.Completion.Wait(new TimeSpan(0,0,0,30))) then
      begin
        _logger.Trace('Timed out waiting after 30 seconds for finish processing messages');
      end
      else
      begin
        _logger.Trace('Stopped finish processing messages');
      end;

      _logger.Trace('Waiting to stop');
      Task.WaitAll(t);
      _logger.Trace('Stopped');

    end;

    method Start;
    begin
      _logger.Trace('Start');

      t := Task.Factory.StartNew( () ->
        begin
          try
            _logger.Trace('Starting');
            repeat

              var someMessage:=_bus.ReceiveAsync(ServerWaitTime).Result;

              if(assigned(someMessage))then
              begin
                _logger.Trace('Posting message');
                var parcel := new MessageParcel(Message := someMessage);
                processMessage.Post(parcel);
              end
              else
              begin
                _logger.Trace('No messages');
              end;

            until token.IsCancellationRequested;
          except
            on e:Exception do
            begin
              _logger.Error(e,'Receiving messages');
              raise;
            end;
          end;
        end, token);

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

    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    begin
      exit _client.Send<T>(methodCall);
    end;

    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;
    begin
      exit _client.Send<T>(methodCall);
    end;

  end;

end.