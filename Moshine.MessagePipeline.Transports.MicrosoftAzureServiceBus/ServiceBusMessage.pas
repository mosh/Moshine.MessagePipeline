namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  Azure.Messaging.ServiceBus,
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading,
  System.Threading.Tasks;
type

  ServiceBusMessage = public class(IMessage)
  private
    property Logger: ILogger;

    _message:ServiceBusReceivedMessage;
    _receiver:ServiceBusReceiver;
  public

    // identification attribute for queues
    const IdAttribute:String = 'Id';

    constructor(receiver:ServiceBusReceiver; message:ServiceBusReceivedMessage; loggerImpl:ILogger);
    begin
      _message := message;
      _receiver := receiver;
      Logger := loggerImpl;
    end;

    constructor(message:ServiceBusReceivedMessage);
    begin
      _message := message;
      Logger.LogTrace($'DeliveryCoint {_message.DeliveryCount}');

    end;

    property Id:Guid read
      begin
        exit Guid.Parse(_message.ApplicationProperties[IdAttribute].ToString);
      end;


    method Clone: IMessage;
    begin
      exit new ServiceBusMessage(_receiver, _message, Logger);
    end;

    method GetBody: String;
    begin
      var messageBody := _message.Body;
      if(not assigned(messageBody))then
      begin
        Logger.LogTrace('MessageBody is null');
        exit nil;
      end;
      exit Encoding.UTF8.GetString(messageBody);
    end;

    method AsErrorAsync(cancellationToken:CancellationToken):Task;
    begin
      if(not assigned(_receiver))then
      begin
        var message := 'Cannot AsError receiver not assigned';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;
      await _receiver.AbandonMessageAsync(_message, cancellationToken);
      Logger.LogTrace('AsError');
    end;

    method CompleteAsync(cancellationToken:CancellationToken):Task;
    begin
      if(not assigned(_receiver))then
      begin
        var message := 'Cannot complete receiver not assigned';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;
      await _receiver.CompleteMessageAsync(_message, cancellationToken);
      Logger.LogTrace('Completed');
    end;

    property InternalMessage:ServiceBusReceivedMessage read
      begin
        exit _message;
      end;


  end;
end.