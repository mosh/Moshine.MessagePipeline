namespace Moshine.MessagePipeline.Transports.AmazonSQS;

type
  IAmazonConfiguration = public interface
    property Credentials:String;
    property Profile:String;
    property ServiceUrl:String ;
    property QueueName:String;
    property AccountId:String;
  end;

end.