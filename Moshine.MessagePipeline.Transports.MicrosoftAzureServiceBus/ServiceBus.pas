﻿namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus;

uses
  NLog,
  Microsoft.Azure.ServiceBus,
  Microsoft.Azure.ServiceBus.Core,
  Moshine.MessagePipeline.Core,
  System.Text,
  System.Threading.Tasks;

type

  ServiceBus = public class(IBus)
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    _topicName:String;
    _subscriptionName:String;
    _connectionString:String;
    _topicClient:TopicClient;
    _subscriptionClient:SubscriptionClient;
    _subscriptionReceiver:IMessageReceiver;
  public
    constructor(connectionString:String; topicName:String; subscriptionName:String);
    begin
      _topicName := topicName;
      _connectionString := connectionString;
      _subscriptionName := subscriptionName;
    end;

    method Initialize;
    begin
      Logger.Info('Initialize');
      _topicClient := new TopicClient(_connectionString, _topicName);
      _subscriptionClient := new SubscriptionClient(_connectionString, _topicName, _subscriptionName);
      var subscriptionPath: String := EntityNameHelper.FormatSubscriptionPath(_topicName, _subscriptionName);
      _subscriptionReceiver := new MessageReceiver(_connectionString, subscriptionPath, ReceiveMode.ReceiveAndDelete);

    end;

    method SendAsync(message: IMessage): Task;
    begin
      var internalMessage := (message as ServiceBusMessage).InternalMessage;
      Logger.Info('Send');
      await _topicClient.SendAsync(internalMessage);
      Logger.Info('Sent');
    end;

    method SendAsync(messageContent: String; id: String): Task;
    begin
      var message := new Message(Encoding.UTF8.GetBytes(messageContent));
      message.UserProperties.Add('Id',id);
      Logger.Info('Send');
      await _topicClient.SendAsync(message);
      Logger.Info('Sent');
    end;

    method ReceiveAsync(serverWaitTime: TimeSpan): Task<IMessage>;
    begin
      Logger.Info('Receive');
      var receivedMessage := await _subscriptionReceiver.ReceiveAsync(serverWaitTime);

      if(assigned(receivedMessage))then
      begin
        Logger.Info('Received message');
        exit new ServiceBusMessage(_subscriptionReceiver, receivedMessage)
      end;
      Logger.Info('Received no message');
      exit nil;
    end;

    method CannotBeProcessedAsync(message: IMessage): Task;
    begin
      Logger.Info('CannotBeProcessed');

      var clone := message.Clone;
      clone.AsError;
      await self.SendAsync(clone);
      message.Complete;

    end;

  end;
end.