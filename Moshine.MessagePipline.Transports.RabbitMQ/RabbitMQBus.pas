namespace Moshine.MessagePipline.Transports.RabbitMQ;

uses
  Moshine.MessagePipeline.Core;

type

  RabbitMQBus = public class(IBus)
  private
  protected
  public
    method Initialize;
    begin

    end;

    method Send(messageContent:String;id:String);
    begin

    end;

    method Send(message:IMessage);
    begin

    end;

    method Receive(serverWaitTime:TimeSpan):IMessage;
    begin

    end;

  end;

end.
