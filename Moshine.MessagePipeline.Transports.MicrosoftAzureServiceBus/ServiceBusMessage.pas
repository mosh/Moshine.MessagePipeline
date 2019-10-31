namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  Moshine.MessagePipeline.Core,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  System.Text,
  System.Threading.Tasks;
type

  ServiceBusMessage = public class(IMessage)
  private
    _message:Message;
    _receiver:IMessageReceiver;
  public

    constructor(receiver:IMessageReceiver; message:Message);
    begin
      _message := message;
      _receiver := receiver;
    end;

    constructor(message:Message);
    begin
      _message := message;
    end;


    method Clone: IMessage;
    begin
      exit new ServiceBusMessage(_receiver, _message.Clone);
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
      Console.WriteLine('AsError');
    end;

    method CompleteAsync:Task;
    begin
      if(not assigned(_receiver))then
      begin
        raise new ApplicationException('Cannot complete receiver not assigned');
      end;
      await _receiver.CompleteAsync(_message.SystemProperties.LockToken);
      Console.WriteLine('Completed');
    end;

    property InternalMessage:Message read
      begin
        exit _message;
      end;


  end;
end.