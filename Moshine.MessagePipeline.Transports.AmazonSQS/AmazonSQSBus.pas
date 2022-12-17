namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.Runtime,
  Amazon.Runtime.CredentialManagement,
  Amazon.SQS,
  Amazon.SQS.Model,
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  System,
  System.Linq,
  System.Threading,
  System.Threading.Tasks;

type

  AmazonSQSBus = public class(IBus)
  private
    property Logger: ILogger;

    _config:AmazonSQSConfig;
    _credentials:AWSCredentials;
    _client:AmazonSQSClient;
    _serviceUrl:String;
    _queueName:String;
    _accountId:String;
    _url:GetQueueUrlResponse;

    method Guard;
    begin
      if ((not assigned(_url)) or (not assigned(_client)))then
      begin
        raise new ApplicationException('Initialize has not been called');
      end;
    end;


    method SendMessageAsync(id:Guid; messageBody:String; cancellationToken:CancellationToken := default):Task<SendMessageResponse>;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := _url.QueueUrl;
        messageRequest.MessageBody := messageBody;

        if(IsFifo)then
        begin
          messageRequest.MessageDeduplicationId := id.ToString;
          messageRequest.MessageGroupId := id.ToString;
        end
        else
        begin
          var attribute := new MessageAttributeValue();
          attribute.DataType := 'String';
          attribute.StringValue := id.ToString;
          messageRequest.MessageAttributes.Add(AmazonSQSMessage.IdAttribute,attribute);
        end;


        exit await _client.SendMessageAsync(messageRequest, cancellationToken);

      except
        on E:Exception do
        begin
          Console.WriteLine(E.Message);
          raise;
        end;
      end;

    end;

  public

    constructor (configuration:IAmazonConfiguration;loggerImpl:ILogger);
    begin

      _serviceUrl := configuration.ServiceUrl;
      _accountId := configuration.AccountId;
      _queueName := configuration.QueueName;

      _config := new AmazonSQSConfig;
      _config.ServiceURL := _serviceUrl;

      var chain := new CredentialProfileStoreChain(configuration.Credentials);
      chain.TryGetAWSCredentials(configuration.Profile, out _credentials);

      Logger := loggerImpl;


    end;

    property Url:GetQueueUrlResponse read _url;

    // The duration (in seconds) that the received messages are hidden from subsequent retrieve requests
    // after being retrieved by a ReceiveMessage request.

    property VisibilityTimeout:Integer := 60*15; // 15 minutes;

    property IsFifo:Boolean read
      begin
        exit _url.QueueUrl.Contains('.fifo',StringComparison.InvariantCultureIgnoreCase);
      end;

    method InitializeAsync:Task;
    begin
      if(not(assigned(_credentials)))then
      begin
        raise new ApplicationException('No credentials');
      end;

      _client := new AmazonSQSClient(_credentials,_config);

      var request := new GetQueueUrlRequest;

      request.QueueName := _queueName;
      request.QueueOwnerAWSAccountId := _accountId;

      _url := await _client.GetQueueUrlAsync(request);

    end;

    method SendAsync(messageContent:String;id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      await SendMessageAsync(id, messageContent, cancellationToken);
    end;

    method SendAsync(message:IMessage; cancellationToken:CancellationToken := default):Task;
    begin
      var amazonMessage := message as AmazonSQSMessage;
      await SendMessageAsync(amazonMessage.Id, amazonMessage.GetBody, cancellationToken);
    end;

    method DeleteMessageAsync(message:Message; cancellationToken:CancellationToken := default):Task;
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := _url.QueueUrl;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      await _client.DeleteMessageAsync(deleteMessageRequest, cancellationToken);
    end;

    method ReturnMessageAsync(receiptHandle:String; cancellationToken:CancellationToken := default):Task;
    begin

      var request := new ChangeMessageVisibilityRequest;
      request.QueueUrl := _url.QueueUrl;
      request.ReceiptHandle := receiptHandle;
      request.VisibilityTimeout := 0;

      await _client.ChangeMessageVisibilityAsync(request, cancellationToken);

    end;

    method ReceiveAsync(serverWaitTime:TimeSpan; cancellationToken:CancellationToken := default):Task<IMessage>;
    begin
      Guard;

      var receiveMessageRequest := new ReceiveMessageRequest();
      if(not IsFifo)then
      begin
        receiveMessageRequest.MessageAttributeNames.Add(AmazonSQSMessage.IdAttribute);
      end;
      receiveMessageRequest.WaitTimeSeconds := Int32(serverWaitTime.TotalSeconds);
      receiveMessageRequest.VisibilityTimeout := VisibilityTimeout;
      receiveMessageRequest.MaxNumberOfMessages := 1; // only return 1 message
      receiveMessageRequest.QueueUrl := _url.QueueUrl;

      var receiveMessageResponse := await _client.ReceiveMessageAsync(receiveMessageRequest, cancellationToken);

      var someMessage := receiveMessageResponse.Messages.FirstOrDefault;

      exit iif(assigned(someMessage),new AmazonSQSMessage(self,someMessage),nil);

    end;

  end;

end.