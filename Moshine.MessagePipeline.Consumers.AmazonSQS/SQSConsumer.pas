namespace Moshine.MessagePipeline.Consumers.AmazonSQS;

uses
  Amazon.Lambda.Core,
  Amazon.Lambda.SQSEvents,
  Amazon.Sqs,
  Amazon.SQS.Model,
  Microsoft.Extensions.DependencyInjection,
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline,
  Moshine.MessagePipeline.Transports.BodyTransport,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  Moshine.MessagePipeline.Scope, System.Threading;

type

  SQSConsumer = public abstract class

  private
    _parcelReceiver:IParcelReceiver;
    _bodyMessageBuilder:IBodyMessageBuilder;


  public

    constructor;
    begin

      var collection := new ServiceCollection;

      var callingAssembly := typeOf(SQSConsumer).Assembly.GetCallingAssembly;

      var typeInCallingAssembly := callingAssembly.GetTypes.FirstOrDefault(t ->
          begin
            var attrs := t.GetCustomAttributes(typeOf(ServiceStartupAttribute),false);
            exit assigned(attrs);
          end);

      if(assigned(typeInCallingAssembly))then
      begin
        var cons := typeInCallingAssembly.GetConstructor([]);

        var instance := cons.Invoke([]);

        var methodInfo := typeInCallingAssembly.GetMethod('Configure',[collection.GetType]);
        if(assigned(methodInfo))then
        begin
          methodInfo.Invoke(instance,[collection]);
        end
        else
        begin
          raise new NotImplementedException('Class with ServiceStartup Attribute does not contain Configure method.');
        end;

      end
      else
      begin
        raise new NotImplementedException('Cannot find class with ServiceStartup Attribute');
      end;

      var serviceProvider := collection.BuildServiceProvider;

      var parcelReceiver:IParcelReceiver := serviceProvider.GetService<IParcelReceiver>;
      var bodyMessageBuilder:IBodyMessageBuilder := serviceProvider.GetService<IBodyMessageBuilder>;

      constructor(parcelReceiver, bodyMessageBuilder);

    end;

    constructor(parcelReceiver:IParcelReceiver; bodyMessageBuilder:IBodyMessageBuilder);
    begin
      _parcelReceiver := parcelReceiver;
      _bodyMessageBuilder := bodyMessageBuilder;
      if(not assigned(_parcelReceiver))then
      begin
        raise new ApplicationException('IParcelReceiver not provided');
      end;
      if(not assigned(_bodyMessageBuilder))then
      begin
        raise new ApplicationException('IBodyMessageBuilder not provided');
      end;

    end;

    method ParameterTypes:List<&Type>; abstract;

    method FunctionHandlerAsync(&event:SQSEvent; context:ILambdaContext):Task<SQSBatchResponse>;
    begin
      var batchFailures := new List<SQSBatchResponse.BatchItemFailure>;

      try

        var tokenSource := new CancellationTokenSource(TimeSpan.FromSeconds(25));
        var token := tokenSource.Token;


        for each &record in &event.Records do
        begin
          try

            context.Logger.LogInformation($'Processing message with Id [{&record.MessageId}]');

            var parcel := new MessageParcel;
            parcel.Message := _bodyMessageBuilder.Build(&record.Body);
            await _parcelReceiver.ReceiveAsync(parcel, token);

            context.Logger.LogInformation($'Processed message with Id [{&record.MessageId}]');

          except
            on TaskCanceledException do
            begin
              raise;
            end
            on ex:Exception do
            begin
              context.Logger.LogError($'Message with Id {&record.MessageId} failed with exception {ex.Message}');
              batchFailures.Add( new SQSBatchResponse.BatchItemFailure(ItemIdentifier := &record.MessageId));
            end;
          end;
        end;
      except
        on TaskCanceledException do
        begin
          context.Logger.LogError('Task cancelled, failing all messages');
          raise;
        end;
      end;

      if(batchFailures.Any)then
      begin
        context.Logger.LogInformation($'{batchFailures.Count} failed out of {&event.Records.Count} messages failed');
      end;

      exit new SQSBatchResponse(batchFailures);

    end;
  end;

end.