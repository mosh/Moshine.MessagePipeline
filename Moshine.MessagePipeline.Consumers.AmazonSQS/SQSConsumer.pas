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
  Moshine.MessagePipeline.Scope;

type

  SQSConsumer = public abstract class

  private
    _parcelReceiver:IParcelReceiver;
    _bodyMessageBuilder:IBodyMessageBuilder;

    method DeleteMessageAsync(message:SQSEvent.SQSMessage):Task;
    begin
      var queueName := Environment.GetEnvironmentVariable('SQSqueueName');

      var client := new AmazonSQSClient;
      var deleteMessageRequest := new DeleteMessageRequest;

      deleteMessageRequest.QueueUrl := queueName;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      await client.DeleteMessageAsync(deleteMessageRequest);

    end;

  protected

    method GetSystemConfig:ISystemConfig; abstract;
    method GetServiceTypes:ITypeFinder; abstract;
    method GetServiceFactory(logger:ILogger; systemConfig:ISystemConfig):IServiceFactory; abstract;

    method Configure:IServiceCollection; virtual;
    begin
      var services := new ServiceCollection;

      services.AddSingleton<ISystemConfig>(container ->
        begin
          exit GetSystemConfig;
        end);

      services.AddLogging(loggingBuilder ->  // AddLogging() requires Microsoft.Extensions.Logging NuGet package
        begin
            loggingBuilder.ClearProviders();
            loggingBuilder.AddConsole(); // AddConsole() requires Microsoft.Extensions.Logging.Console NuGet package
        end);

      services.AddSingleton<ICache>(container ->
        begin
          exit new NullCache;
        end);

      services.AddSingleton<IScopeProvider>(container -> begin
        var repository := container.GetService<IOutboxRepository>;
        exit new TransactionalScopeProvider(repository);
      end);

      services.AddSingleton<IManager>(container -> begin
        var repository := container.GetService<IOutboxRepository>;
        exit new DeduplicatingManager(repository);
      end);

      services.AddSingleton<IActionInvokerHelpers>(container ->
        begin
          var logger := container.GetService<ILogger>;
          var serviceFactory := container.GetService<IServiceFactory>;
          var typeFinder := container.GetService<ITypeFinder>;
          exit new ActionInvokerHelpers(serviceFactory, typeFinder, logger);

        end);

      services.AddSingleton<IServiceFactory>(container ->
        begin
          var logger := container.GetService<ILogger>;
          var systemConfig := container.GetService<ISystemConfig>;
          exit GetServiceFactory(logger, systemConfig);
        end);

      services.AddSingleton<ITypeFinder>(container ->
        begin
          exit GetServiceTypes;
        end);

      services.AddSingleton<IParcelProcessor>(container -> begin

        var actionSerializer := new PipelineSerializer<SavedAction>(ParameterTypes());
        var helpers := container.GetService<IActionInvokerHelpers>;
        var cache := container.GetService<ICache>;
        var scopeProvider := container.GetService<IScopeProvider>;
        var manager := container.GetService<IManager>;
        var logger := container.GetService<ILogger>;

        exit new ParcelProcessor(actionSerializer, helpers, cache, scopeProvider, manager, logger);

      end);

      services.AddSingleton<IParcelReceiver>(container -> begin

          var processor := container.GetService<IParcelProcessor>;

          exit new ParcelReceiver(processor);
        end);

      services.AddSingleton<IBodyMessageBuilder>(container -> begin

        var actionSerializer := new PipelineSerializer<SavedAction>(ParameterTypes());
        exit new BodyMessageBuilder(actionSerializer);

      end);

      exit services;
    end;


  public

    constructor;
    begin

      var configuredServices := Configure;
      var serviceProvider := configuredServices.BuildServiceProvider;

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

    method FunctionHandlerAsync(&event:SQSEvent; context:ILambdaContext):Task;
    begin
      var raisedExceptions := new List<Exception>;

      for each &record in &event.Records do
        begin
        try
          context.Logger.LogInformation('Processing message');

          var parcel := new MessageParcel;
          parcel.Message := _bodyMessageBuilder.Build(&record.Body);
          await _parcelReceiver.ReceiveAsync(parcel);

          await DeleteMessageAsync(&record);
          context.Logger.LogInformation('Deleted message');
        except
          on ex:Exception do
          begin
            context.Logger.LogError($'MessageId {&record.MessageId} {ex.Message}');
            raisedExceptions.Add(ex);
          end;
        end;
      end;

      if(raisedExceptions.Any)then
      begin
        raise new AggregateException(raisedExceptions);
      end;


    end;
  end;

end.