namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.Models;

type
  ServiceBusConnectionInformation = public class(IServiceBusConnectionInformation)
  public
    property ConnectionString:String;
    property TopicName:String;
    property SubscriptionName:String;

  end;

end.