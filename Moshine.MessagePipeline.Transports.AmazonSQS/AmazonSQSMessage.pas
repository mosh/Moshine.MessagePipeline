namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core,
  System,
  System.Threading,
  System.Threading.Tasks;

type

  AmazonSQSMessage = public class(IMessage)
  private
    _message:Message;
    _sendMessageRequest:SendMessageRequest;
    _bus : AmazonSQSBus;
    _receiptHandle:String;


  protected
  public

    // identification attribute for standard queues
    const IdAttribute:String = 'Id';

    // constructing with a message that has been received
    constructor(bus:AmazonSQSBus; message:Message);
    begin
      _bus := bus;
      _message := message;
    end;

    // constructing with message that we intend to send
    constructor(bus:AmazonSQSBus; sendMessageRequest:SendMessageRequest; receiptMessageHandle:String);
    begin
      _bus := bus;
      _sendMessageRequest := sendMessageRequest;
      _receiptHandle := receiptMessageHandle;
    end;

    property InternalMessage:Message read
      begin
        exit _message;
      end;

    property ReceiptHandle:String read
      begin
        if(assigned(_message))then
        begin
          exit _message.ReceiptHandle;
        end;
        exit _receiptHandle;
      end;

    property Id:Guid read
      begin
        var value:String;
        if(_bus.IsFifo)then
        begin
          value := iif(assigned(_message), _message.MessageId, _sendMessageRequest.MessageDeduplicationId);
        end
        else
        begin
          var attribute := _message.MessageAttributes[IdAttribute];
          value := attribute.StringValue;
        end;
        exit Guid.Parse(value);
      end;


    method Clone:IMessage;
    begin
      var sendMessageRequest := new SendMessageRequest;
      sendMessageRequest.QueueUrl := _bus.Url;
      sendMessageRequest.MessageBody := self.GetBody;
      if(_bus.IsFifo)then
      begin
        sendMessageRequest.MessageDeduplicationId := self.Id.ToString;
        sendMessageRequest.MessageGroupId := self.Id.ToString;
      end
      else
      begin
        var attribute := new MessageAttributeValue();
        attribute.DataType := 'String';
        attribute.StringValue := Id.ToString;
        sendMessageRequest.MessageAttributes.Add(IdAttribute,attribute);
      end;
      exit new AmazonSQSMessage(_bus, sendMessageRequest,InternalMessage.ReceiptHandle);
    end;

    method GetBody:String;
    begin
      exit iif(assigned(_message), _message.Body, _sendMessageRequest.MessageBody);
    end;

    method AsErrorAsync(cancellationToken:CancellationToken := default):Task;
    begin
      if(not _bus.IsFifo)then
      begin
        var receiptForMessageToBeReturned := ReceiptHandle;
        if(String.IsNullOrEmpty(receiptForMessageToBeReturned))then
        begin
          raise new ApplicationException('No receipthandle');
        end;
        await self._bus.ReturnMessageAsync(receiptForMessageToBeReturned, cancellationToken);
      end;
    end;

    method CompleteAsync(cancellationToken:CancellationToken := default):Task;
    begin
      await _bus.DeleteMessageAsync(_message, cancellationToken);
    end;

  end;

end.