namespace Moshine.MessagePipeline.Transports.MicrosoftAzureServiceBus.Models;

type
  IServiceBusConnectionInformation = public interface

    property ConnectionString:String;
    property TopicName:String;
    property SubscriptionName:String;
  end;

end.