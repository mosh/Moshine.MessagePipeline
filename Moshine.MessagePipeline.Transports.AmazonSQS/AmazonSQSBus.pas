namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  Amazon.Runtime,
  Amazon.Runtime.CredentialManagement,
  Amazon.SQS,
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core;

type

  AmazonSQSBus = public class(IBus)
  private

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

    method SendMessage(id:String; messageBody:String):SendMessageResponse;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := _url.QueueUrl;
        messageRequest.MessageBody := messageBody;
        messageRequest.MessageDeduplicationId := id;
        messageRequest.MessageGroupId := id;

        exit _client.SendMessage(messageRequest);

      except
        on E:Exception do
        begin
          Console.WriteLine(E.Message);
          raise;
        end;
      end;

    end;


  protected
  public

    constructor (credentialsFilename:String;profileName:String; serviceUrl:String;queueName:String;accountId:String);
    begin

      _serviceUrl := serviceUrl;
      _accountId := accountId;
      _queueName := queueName;

      _config := new AmazonSQSConfig;
      _config.ServiceURL := _serviceUrl;

      var chain := new CredentialProfileStoreChain(credentialsFilename);
      chain.TryGetAWSCredentials(profileName, out _credentials);


    end;

    property Url:GetQueueUrlResponse read _url;


    method Initialize;
    begin
      if(not(assigned(_credentials)))then
      begin
        raise new ApplicationException('No credentials');
      end;

      _client := new AmazonSQSClient(_credentials,_config);

      var request := new GetQueueUrlRequest;

      request.QueueName := _queueName;
      request.QueueOwnerAWSAccountId := _accountId;

      _url := _client.GetQueueUrl(request);


    end;

    method Send(messageContent:String;id:String);
    begin
      SendMessage(id, messageContent);
    end;

    method Send(message:IMessage);
    begin
      var amazonMessage := message as AmazonSQSMessage;

      SendMessage(amazonMessage.GetBody, amazonMessage.Id);

    end;

    method DeleteMessage(message:Message);
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := _url.QueueUrl;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      _client.DeleteMessage(deleteMessageRequest);
    end;

    method Receive(serverWaitTime:TimeSpan):IMessage;
    begin
      Guard;

      var receiveMessageRequest := new ReceiveMessageRequest();
      receiveMessageRequest.WaitTimeSeconds := Int32(serverWaitTime.TotalSeconds);
      receiveMessageRequest.QueueUrl := _url.QueueUrl;

      var receiveMessageResponse := _client.ReceiveMessage(receiveMessageRequest);

      var someMessage := receiveMessageResponse.Messages.FirstOrDefault;

      exit iif(assigned(someMessage),new AmazonSQSMessage(self,someMessage),nil);

    end;

  end;

end.