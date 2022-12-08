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


    method SendMessageAsync(id:Guid; messageBody:String):Task<SendMessageResponse>;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := _url.QueueUrl;
        messageRequest.MessageBody := messageBody;
        messageRequest.MessageDeduplicationId := id.ToString;
        messageRequest.MessageGroupId := id.ToString;

        exit await _client.SendMessageAsync(messageRequest);

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

      _url := _client.GetQueueUrlAsync(request).Result;

      exit Task.CompletedTask;
    end;

    method SendAsync(messageContent:String;id:Guid):Task;
    begin
      await SendMessageAsync(id, messageContent);
    end;

    method SendAsync(message:IMessage):Task;
    begin
      var amazonMessage := message as AmazonSQSMessage;
      await SendMessageAsync(amazonMessage.Id, amazonMessage.GetBody);
    end;

    method DeleteMessageAsync(message:Message):Task;
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := _url.QueueUrl;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      await _client.DeleteMessageAsync(deleteMessageRequest);
    end;

    method ReturnMessage(message:Message);
    begin

      var request := new ChangeMessageVisibilityRequest;
      request.QueueUrl := _url.QueueUrl;
      request.ReceiptHandle := message.ReceiptHandle;
      request.VisibilityTimeout := 0;

      _client.ChangeMessageVisibilityAsync(request).Wait;

    end;

    method ReceiveAsync(serverWaitTime:TimeSpan):Task<IMessage>;
    begin
      Guard;

      var receiveMessageRequest := new ReceiveMessageRequest();
      receiveMessageRequest.WaitTimeSeconds := Int32(serverWaitTime.TotalSeconds);
      receiveMessageRequest.VisibilityTimeout := VisibilityTimeout;
      receiveMessageRequest.MaxNumberOfMessages := 1; // only return 1 message
      receiveMessageRequest.QueueUrl := _url.QueueUrl;

      var receiveMessageResponse := await _client.ReceiveMessageAsync(receiveMessageRequest);

      var someMessage := receiveMessageResponse.Messages.FirstOrDefault;

      exit iif(assigned(someMessage),new AmazonSQSMessage(self,someMessage),nil);

    end;

  end;

end.