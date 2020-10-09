namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  System.Text,
  System.Threading.Tasks;
type

  ServiceBusMessage = public class(IMessage)
  private
    property Logger: ILogger;

    _message:Message;
    _receiver:IMessageReceiver;
  public

    constructor(receiver:IMessageReceiver; message:Message; loggerImpl:ILogger);
    begin
      _message := message;
      _receiver := receiver;
      Logger := loggerImpl;
    end;

    constructor(message:Message);
    begin
      _message := message;
      Logger.LogTrace($'DeliveryCoint {_message.SystemProperties.DeliveryCount}');

    end;


    method Clone: IMessage;
    begin
      exit new ServiceBusMessage(_receiver, _message.Clone, Logger);
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

    method AsErrorAsync:Task;
    begin
      if(not assigned(_receiver))then
      begin
        var message := 'Cannot AsError receiver not assigned';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;
      await _receiver.AbandonAsync(_message.SystemProperties.LockToken);
      Logger.LogTrace('AsError');
    end;

    method CompleteAsync:Task;
    begin
      if(not assigned(_receiver))then
      begin
        var message := 'Cannot complete receiver not assigned';
        Logger.LogError(message);
        raise new ApplicationException(message);
      end;
      await _receiver.CompleteAsync(_message.SystemProperties.LockToken);
      Logger.LogTrace('Completed');
    end;

    property InternalMessage:Message read
      begin
        exit _message;
      end;


  end;
end.