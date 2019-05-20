﻿namespace Moshine.MessagePipeline;

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


    method Initialize(parameterTypes:List<&Type>);
    begin
      _bus.Initialize;

      _actionSerializer := new PipelineSerializer<SavedAction>(parameterTypes);

      SetupPipeline;

    end;

    method Load(someAction:SavedAction);
    begin
      HandleTrace('Invoking action');

      var returnValue := _actionInvokerHelpers.InvokeAction(someAction);

      if(assigned(returnValue))then
      begin
        _cache.Add(someAction.Id.ToString,returnValue);

      end;

    end;


    method HandleTrace(message:String);
    begin
      if(assigned(self.TraceCallback))then
      begin
        self.TraceCallback(message);
      end;
    end;


    method HandleException(e:Exception);
    begin
      if(assigned(self.ErrorCallback))then
      begin
        self.ErrorCallback(e);
      end;
    end;

    method SetupPipeline;
    begin
      processMessage := new TransformBlock<MessageParcel, MessageParcel>(parcel ->
          begin
            try
              HandleTrace('ProcessMessage');

              var body := parcel.Message.GetBody;
              var savedAction := _actionSerializer.Deserialize<SavedAction>(body);
              using scope := new TransactionScope(TransactionScopeOption.RequiresNew) do
              begin
                HandleTrace('LoadAction');
                Load(savedAction);
                scope.Complete;
              end;
              parcel.State := MessageStateEnum.Processed;
            except
              on E:Exception do
              begin
                HandleException(E);
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
            HandleTrace('Fault in processing');
            try

              using scope := new TransactionScope do
              begin

                _bus.CannotBeProcessedAsync(parcel.Message).Wait;

                scope.Complete;
              end;

            except
              on e:Exception do
              begin
                HandleException(e);
                raise;
              end;
            end;
          end);

      finishProcessing := new ActionBlock<MessageParcel>(parcel ->
          begin
            HandleTrace('Finished processing');
            try
              parcel.Message.Complete;
            except
              on e:Exception do
              begin
                HandleException(e);
                raise;
              end;
            end;
          end);

      processMessage.LinkTo(finishProcessing, p -> p.State = MessageStateEnum.Processed);
      processMessage.LinkTo(processMessage, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount < self._maxRetries));
      processMessage.LinkTo(faultedInProcessing, p -> (p.State = MessageStateEnum.Faulted) and (p.ReTryCount >= self._maxRetries));

    end;



  public

    constructor(factory:IServiceFactory; cache:ICache;bus:IBus);
    begin
      _maxRetries := 4;
      _cache:=cache;
      _bus:= bus;

      _actionInvokerHelpers := new ActionInvokerHelpers(factory);

      tokenSource := new CancellationTokenSource();
      token := tokenSource.Token;

      _client := new PipelineClient(bus);

    end;

    method Stop;
    begin
      HandleTrace('Token cancelled');
      tokenSource.Cancel;

      processMessage.Complete();
      HandleTrace('Stopped processing messages');
      if(not finishProcessing.Completion.Wait(new TimeSpan(0,0,0,30))) then
      begin
        HandleTrace('Timed out waiting after 30 seconds for finish processing messages');
      end
      else
      begin
        HandleTrace('Stopped finish processing messages');
      end;

      HandleTrace('Waiting to stop');
      Task.WaitAll(t);
      HandleTrace('Stopped');

    end;

    method Start;
    begin
      HandleTrace('Start');

      t := Task.Factory.StartNew( () ->
        begin
          try

            repeat
              var serverWaitTime := new TimeSpan(0,0,2);

              var someMessage:=_bus.ReceiveAsync(serverWaitTime).Result;

              if(assigned(someMessage))then
              begin
                HandleTrace('Posting message');
                var parcel := new MessageParcel(Message := someMessage);
                processMessage.Post(parcel);
              end;

            until token.IsCancellationRequested;
          except
            on e:Exception do
            begin
              HandleException(e);
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


    property ErrorCallback:Action<Exception>;
    property TraceCallback:Action<String>;

  end;

end.