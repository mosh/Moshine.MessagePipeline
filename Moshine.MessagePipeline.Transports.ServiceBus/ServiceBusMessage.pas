namespace Moshine.MessagePipeline.Transports.ServiceBus;

uses
  System,
  Moshine.MessagePipeline.Core,
  Microsoft.ServiceBus.Messaging;

type
  [Obsolete('Use Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.ServiceBusMessage')]
  ServiceBusMessage = public class(IMessage)

  private
    _message:BrokeredMessage;

  public
    constructor(message:BrokeredMessage);
    begin
      _message := message;
    end;

    property InternalMessage:BrokeredMessage read
      begin
        exit _message;
      end;


    method Clone: IMessage;
    begin
      exit new ServiceBusMessage(_message.Clone);
    end;

    method GetBody: String;
    begin
      exit _message.GetBody<String>;
    end;

    method AsError;
    begin
      _message.Properties.Remove('State');
      _message.Properties.Add('State','Error');
    end;

    method Complete;
    begin
      _message.Complete;
    end;

  end;

end.