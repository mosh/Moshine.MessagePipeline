namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core,
  System;

type

  AmazonSQSMessage = public class(IMessage)
  private
    _message:Message;
    _bus : AmazonSQSBus;

    method get_InternalMessage: Message;
    begin
      exit _message;
    end;

  protected
  public

    constructor(bus:AmazonSQSBus; message:Message);
    begin
      _bus := bus;
      _message := message;
    end;

    property InternalMessage:Message read get_InternalMessage;

    method Clone:IMessage;
    begin

    end;

    method GetBody:String;
    begin
      exit _message.Body;
    end;

    method AsError;
    begin

    end;

    method Complete;
    begin
      _bus.DeleteMessage(_message);

    end;

  end;

end.