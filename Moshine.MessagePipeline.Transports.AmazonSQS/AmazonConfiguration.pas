namespace Moshine.MessagePipeline.Transports.AmazonSQS;

type
  AmazonConfiguration = public class(IAmazonConfiguration)
  public
    property Credentials:String;
    property Profile:String;
    property ServiceUrl:String ;
    property QueueName:String;
    property AccountId:String;
  end;

end.