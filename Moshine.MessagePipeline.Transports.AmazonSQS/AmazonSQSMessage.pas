namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core,
  System,
  System.Threading.Tasks;

type

  AmazonSQSMessage = public class(IMessage)
  private
    _message:Message;
    _sendMessageRequest:SendMessageRequest;
    _bus : AmazonSQSBus;


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

    property InternalMessage:Message read
      begin
        exit _message;
      end;

    property Id:Guid read
      begin
        var value := iif(assigned(_message), _message.MessageId, _sendMessageRequest.MessageDeduplicationId);
        exit Guid.Parse(value);
      end;


    method Clone:IMessage;
    begin
      var sendMessageRequest := new SendMessageRequest;
      sendMessageRequest.QueueUrl := _bus.Url.QueueUrl;
      sendMessageRequest.MessageBody := self.GetBody;
      sendMessageRequest.MessageDeduplicationId := self.Id.ToString;
      sendMessageRequest.MessageGroupId := self.Id.ToString;
      exit new AmazonSQSMessage(_bus, sendMessageRequest);
    end;

    method GetBody:String;
    begin
      exit iif(assigned(_message), _message.Body, _sendMessageRequest.MessageBody);
    end;

    method AsErrorAsync:Task;
    begin
      // assuming we have setup a dead-letter queue this shouldnt be required
      // also
      if(not assigned(_message))then
      begin
        raise new ApplicationException('No available message');
      end;

      await self._bus.ReturnMessageAsync(_message);
    end;

    method CompleteAsync:Task;
    begin
      await _bus.DeleteMessageAsync(_message);
    end;

  end;

end.