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
      exit Encoding.UTF8.GetString(_message.Body);
    end;

    method AsErrorAsync:Task;
    begin
      if(not assigned(_receiver))then
      begin
        raise new ApplicationException('Cannot AsError receiver not assigned');
      end;
      await _receiver.AbandonAsync(_message.SystemProperties.LockToken);
      Logger.LogInformation('AsError');
    end;

    method CompleteAsync:Task;
    begin
      if(not assigned(_receiver))then
      begin
        raise new ApplicationException('Cannot complete receiver not assigned');
      end;
      await _receiver.CompleteAsync(_message.SystemProperties.LockToken);
      Logger.LogInformation('Completed');
    end;

    property InternalMessage:Message read
      begin
        exit _message;
      end;


  end;
end.