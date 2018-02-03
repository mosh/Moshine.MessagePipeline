namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core,
  System;

type

  AmazonSQSMessage = public class(IMessage)
  private
    _message:Message;
    _sendMessageRequest:SendMessageRequest;
    _bus : AmazonSQSBus;

    method get_InternalMessage: Message;
    begin
      exit _message;
    end;

    method get_Id:String;
    begin
      exit iif(assigned(_message), _message.MessageId, _sendMessageRequest.MessageDeduplicationId);
    end;

  protected
  public

    // constructing with a message that has been received
    constructor(bus:AmazonSQSBus; message:Message);
    begin
      _bus := bus;
      _message := message;
    end;

    // constructing with message that we intend to send
    constructor(bus:AmazonSQSBus; sendMessageRequest:SendMessageRequest);
    begin
      _bus := bus;
      _sendMessageRequest := sendMessageRequest;
    end;

    property InternalMessage:Message read get_InternalMessage;
    property Id:String read get_Id;

    method Clone:IMessage;
    begin
      var sendMessageRequest := new SendMessageRequest;
      sendMessageRequest.QueueUrl := _bus.Url.QueueUrl;
      sendMessageRequest.MessageBody := self.GetBody;
      sendMessageRequest.MessageDeduplicationId := self.Id;
      sendMessageRequest.MessageGroupId := self.Id;
      exit new AmazonSQSMessage(_bus, sendMessageRequest);
    end;

    method GetBody:String;
    begin
      exit iif(assigned(_message), _message.Body, _sendMessageRequest.MessageBody);
    end;

    method AsError;
    begin
      // assuming we have setup a dead-letter queue this shouldnt be required
      // also
    end;

    method Complete;
    begin
      _bus.DeleteMessage(_message);

    end;

  end;

end.