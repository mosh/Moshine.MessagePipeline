﻿namespace Moshine.MessagePipeline.Transports.AmazonSQS;

uses
  System,
  System.Linq,
  Amazon.Runtime,
  Amazon.Runtime.CredentialManagement,
  Amazon.SQS,
  Amazon.SQS.Model,
  Moshine.MessagePipeline.Core, System.Threading.Tasks;

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


    method SendMessageAsync(id:String; messageBody:String):Task<SendMessageResponse>;
    begin
      Guard;

      try
        var messageRequest := new SendMessageRequest;
        messageRequest.QueueUrl := _url.QueueUrl;
        messageRequest.MessageBody := messageBody;
        messageRequest.MessageDeduplicationId := id;
        messageRequest.MessageGroupId := id;

        exit await _client.SendMessageAsync(messageRequest);

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

    // The duration (in seconds) that the received messages are hidden from subsequent retrieve requests
    // after being retrieved by a ReceiveMessage request.

    property VisibilityTimeout:Integer := 60*15; // 15 minutes;


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

      _url := _client.GetQueueUrlAsync(request).Result;


    end;

    method SendAsync(messageContent:String;id:String):Task;
    begin
      await SendMessageAsync(id, messageContent);
    end;

    method SendAsync(message:IMessage):Task;
    begin
      var amazonMessage := message as AmazonSQSMessage;
      await SendMessageAsync(amazonMessage.GetBody, amazonMessage.Id);
    end;

    method DeleteMessage(message:Message);
    begin
      Guard;
      var deleteMessageRequest := new DeleteMessageRequest();

      deleteMessageRequest.QueueUrl := _url.QueueUrl;
      deleteMessageRequest.ReceiptHandle := message.ReceiptHandle;

      _client.DeleteMessageAsync(deleteMessageRequest).Wait;
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

    method CannotBeProcessedAsync(message:IMessage):Task;
    begin
      var clone := message.Clone;
      clone.AsError;
      exit Task.CompletedTask;
    end;

  end;

end.