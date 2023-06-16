namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon,
  Amazon.Runtime,
  Amazon.Runtime.CredentialManagement,
  Amazon.SQS,
  Amazon.SQS.Model,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Interfaces,
  Moshine.MessagePipeline.Core,
  System,
  System.Linq,
  System.Threading,
  System.Threading.Tasks;

type

  AmazonSQSBus = public class(IBus)
  private
    property Logger: ILogger;

    property Client:AmazonSQSClient;
    property CredentialsFactory:IAWSCredentialsFactory;
    property Region:RegionEndpoint;

    method Guard;
    begin
      if ((String.IsNullOrEmpty(Url)) or (not assigned(Client)))then
      begin
        raise new ApplicationException('Initialize has not been called');
      end;
    end;


    method SendMessageAsync(id:Guid; messageBody:String; cancellationToken:CancellationToken := default):Task<SendMessageResponse>;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := Url;
        messageRequest.MessageBody := messageBody;

        if(IsFifo)then
        begin
          messageRequest.MessageDeduplicationId := id.ToString;
          messageRequest.MessageGroupId := id.ToString;
        end
        else
        begin
          var attribute := new MessageAttributeValue;
          attribute.DataType := 'String';
          attribute.StringValue := id.ToString;
          messageRequest.MessageAttributes.Add(AmazonSQSMessage.IdAttribute,attribute);
        end;


        exit await Client.SendMessageAsync(messageRequest, cancellationToken);

      except
        on E:Exception do
        begin
          Console.WriteLine(E.Message);
          raise;
        end;
      end;

    end;

  public

    property Url:String;

    constructor (urlImpl:String; regionImpl:RegionEndpoint; credentialsFactoryImpl:IAWSCredentialsFactory; loggerImpl:ILogger);
    begin
      Url := urlImpl;
      CredentialsFactory := credentialsFactoryImpl;
      Logger := loggerImpl;
      Region := regionImpl;

    end;

    // The duration (in seconds) that the received messages are hidden from subsequent retrieve requests
    // after being retrieved by a ReceiveMessage request.

    property VisibilityTimeout:Integer := 60*15; // 15 minutes;

    property IsFifo:Boolean read
      begin
        exit Url.Contains('.fifo',StringComparison.InvariantCultureIgnoreCase);
      end;

    method InitializeAsync(cancellationToken:CancellationToken := default):Task;
    begin
      var credentials := CredentialsFactory.Get;
      Client := new AmazonSQSClient(credentials, Region);
      exit Task.CompletedTask;
    end;

    method SendAsync(messageContent:String;id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      var response := await SendMessageAsync(id, messageContent, cancellationToken);

      Logger.LogDebug($'MessageId of sent message is {response.MessageId}');
    end;

    method SendAsync(message:IMessage; cancellationToken:CancellationToken := default):Task;
    begin
      var amazonMessage := message as AmazonSQSMessage;
      var response := await SendMessageAsync(amazonMessage.Id, amazonMessage.GetBody, cancellationToken);

      Logger.LogDebug($'MessageId of sent message is {response.MessageId}');
    end;

    method DeleteMessageAsync(message:Message; cancellationToken:CancellationToken := default):Task;
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := Url;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      await Client.DeleteMessageAsync(deleteMessageRequest, cancellationToken);
    end;

    method ReturnMessageAsync(receiptHandle:String; cancellationToken:CancellationToken := default):Task;
    begin

      var request := new ChangeMessageVisibilityRequest;
      request.QueueUrl := Url;
      request.ReceiptHandle := receiptHandle;
      request.VisibilityTimeout := 0;

      await Client.ChangeMessageVisibilityAsync(request, cancellationToken);

    end;

    method ReceiveAsync(serverWaitTime:TimeSpan; cancellationToken:CancellationToken := default):Task<IMessage>;
    begin
      Guard;

      var receiveMessageRequest := new ReceiveMessageRequest;
      if(not IsFifo)then
      begin
        receiveMessageRequest.MessageAttributeNames.Add(AmazonSQSMessage.IdAttribute);
      end;
      receiveMessageRequest.WaitTimeSeconds := Int32(serverWaitTime.TotalSeconds);
      receiveMessageRequest.VisibilityTimeout := VisibilityTimeout;
      receiveMessageRequest.MaxNumberOfMessages := 1; // only return 1 message
      receiveMessageRequest.QueueUrl := Url;

      var receiveMessageResponse := await Client.ReceiveMessageAsync(receiveMessageRequest, cancellationToken);

      var someMessage := receiveMessageResponse.Messages.FirstOrDefault;

      if(assigned(someMessage))then
      begin
        Logger.LogDebug($'MessageId of received message is {someMessage.MessageId}');
      end;

      exit iif(assigned(someMessage),new AmazonSQSMessage(self,someMessage),nil);

    end;

  end;

end.