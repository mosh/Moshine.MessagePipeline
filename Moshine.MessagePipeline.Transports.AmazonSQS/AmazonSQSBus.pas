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
    _logger: ILogger;
    _region: nullable RegionEndpoint;
    _serviceUrl:String;
    _queueName:String;
    _awsAccessKeyId:String;
    _awsSecretAccessKey:String;
    _authenticationRegion:String;

    property Client:AmazonSQSClient;
    property CredentialsFactory:IAWSCredentialsFactory;
    property UsingCredentialsFactory:Boolean;



    method GetQueueUrlAsync(cancellationToken: CancellationToken := default): Task<String>;
    begin
      var request := new GetQueueUrlRequest;
      request.QueueName := _queueName;

      var response := await Client.GetQueueUrlAsync(request, cancellationToken);

      exit response.QueueUrl;
    end;


    method Guard;
    begin
      if ((String.IsNullOrEmpty(self.QueueUrl)) or (not assigned(Client)))then
      begin
        raise new ApplicationException('Initialize has not been called');
      end;
    end;


    method SendMessageAsync(id:Guid; messageBody:String; cancellationToken:CancellationToken := default):Task<SendMessageResponse>;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := self.QueueUrl;
        messageRequest.MessageBody := messageBody;

        if(IsFifo)then
        begin
          messageRequest.MessageDeduplicationId := id.ToString;
          messageRequest.MessageGroupId := id.ToString;
        end
        else
        begin
          _logger.LogDebug('Adding attribute');

          var attribute := new MessageAttributeValue;
          attribute.DataType := 'String';
          attribute.StringValue := id.ToString;
          messageRequest.MessageAttributes := new Dictionary<String, MessageAttributeValue>;
          messageRequest.MessageAttributes.Add(AmazonSQSMessage.IdAttribute,attribute);
        end;


        exit await Client.SendMessageAsync(messageRequest, cancellationToken);

      except
        on E:Exception do
        begin
          _logger.LogError(E.Message, 'Failed to send message');
          raise;
        end;
      end;

    end;

  public

    property QueueUrl:String read private write;

    constructor (serviceUrl:String; queueName:String; awsAccessKeyId:String; awsSecretAccessKey:String; authenticationRegion:String := nil; region:RegionEndpoint := nil; logger:ILogger);
    begin
      _serviceUrl := serviceUrl;
      _queueName := queueName;

      _logger := logger;
      if(region  ≠ nil)then
      begin
        _region := region;
      end;

      if(not String.IsNullOrEmpty(authenticationRegion))then
      begin
        _authenticationRegion := authenticationRegion;
      end;

      UsingCredentialsFactory := false;
      _awsAccessKeyId := awsAccessKeyId;
      _awsSecretAccessKey := awsSecretAccessKey;

    end;


    constructor (serviceUrl:String; queueName:String; region:RegionEndpoint := nil; credentialsFactoryImpl:IAWSCredentialsFactory; logger:ILogger);
    begin

      _serviceUrl := serviceUrl;
      _queueName := queueName;

      CredentialsFactory := credentialsFactoryImpl;
      _logger := logger;
      if(region  ≠ nil)then
      begin
        _region := region;
      end;
      UsingCredentialsFactory := true;

    end;

    // The duration (in seconds) that the received messages are hidden from subsequent retrieve requests
    // after being retrieved by a ReceiveMessage request.

    property VisibilityTimeout:Integer := 60*15; // 15 minutes;

    property IsFifo:Boolean read
      begin
        exit self.QueueUrl.Contains('.fifo',StringComparison.InvariantCultureIgnoreCase);
      end;

    method InitializeAsync(cancellationToken:CancellationToken := default):Task;
    begin

      var config := new AmazonSQSConfig
      (
          ServiceURL := _serviceUrl
      );

      if _region ≠ nil then
      begin
        config.RegionEndpoint := _region;
      end;

      if (not String.IsNullOrEmpty(_authenticationRegion))then
      begin
        config.AuthenticationRegion := _authenticationRegion;
      end;

      if (UsingCredentialsFactory) then
      begin
        _logger.LogDebug('Using credentials');
        var credentials := CredentialsFactory.Get;
        Client := new AmazonSQSClient(credentials, config);

      end
      else
      begin
        _logger.LogDebug('Not using credentials');

        Client := new AmazonSQSClient(_awsAccessKeyId, _awsSecretAccessKey, config);
      end;

      self.QueueUrl := await GetQueueUrlAsync(cancellationToken);
    end;

    method SendAsync(messageContent:String;id:Guid; cancellationToken:CancellationToken := default):Task;
    begin
      var response := await SendMessageAsync(id, messageContent, cancellationToken);

      _logger.LogDebug($'MessageId of sent message is {response.MessageId}');
    end;

    method SendAsync(message:IMessage; cancellationToken:CancellationToken := default):Task;
    begin
      var amazonMessage := message as AmazonSQSMessage;

      var response := await SendMessageAsync(amazonMessage.Id, amazonMessage.GetBody, cancellationToken);

      _logger.LogDebug($'MessageId of sent message is {response.MessageId}');
    end;

    method DeleteMessageAsync(message:Message; cancellationToken:CancellationToken := default):Task;
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := self.QueueUrl;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;
      await Client.DeleteMessageAsync(deleteMessageRequest, cancellationToken);
    end;

    method ReturnMessageAsync(receiptHandle:String; cancellationToken:CancellationToken := default):Task;
    begin

      var request := new ChangeMessageVisibilityRequest;
      request.QueueUrl := self.QueueUrl;
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
        receiveMessageRequest.MessageAttributeNames := new List<String>;
        receiveMessageRequest.MessageAttributeNames.Add(AmazonSQSMessage.IdAttribute);
      end;
      receiveMessageRequest.WaitTimeSeconds := Int32(serverWaitTime.TotalSeconds);
      receiveMessageRequest.VisibilityTimeout := VisibilityTimeout;
      receiveMessageRequest.MaxNumberOfMessages := 1; // only return 1 message
      receiveMessageRequest.QueueUrl := self.QueueUrl;

      var receiveMessageResponse := await Client.ReceiveMessageAsync(receiveMessageRequest, cancellationToken);

      var someMessage := receiveMessageResponse.Messages.FirstOrDefault;

      if(assigned(someMessage))then
      begin
        _logger.LogDebug($'MessageId of received message is {someMessage.MessageId}');
      end;

      exit iif(assigned(someMessage),new AmazonSQSMessage(self,someMessage),nil);

    end;

  end;

end.