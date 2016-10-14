namespace HttpPipelineApplication;

uses
  System.Collections.Generic,
  System.Configuration,
  System.Linq,
  System.Text, 
  Microsoft.WindowsAzure,
  Autofac,
  Moshine.MessagePipeline,
  Moshine.MessagePipeline.Cache,
  Moshine.MessagePipeline.Core,
  Nancy, 
  Nancy.Bootstrapper,
  Nancy.Bootstrappers.Autofac,
  Nancy.Elmah,
  Nancy.TinyIoc, 
  Moshine.MessagePipeline.Transports.ServiceBus,
  StackExchange.Redis;

type

  SomeBootstrapper = public class(AutofacNancyBootstrapper)
  private
  protected
    method ConfigureApplicationContainer(existingContainer:ILifetimeScope);override;
    begin
      inherited.ConfigureApplicationContainer(existingContainer);
    
      var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');
    
      var cache:ICache := new InMemoryCache;
    
      var bus:IBus := new ServiceBus(connectionString,'pipeline');
    
      var builder := new ContainerBuilder();
      builder.Register(c -> begin
                         var obj := new Pipeline(cache,bus);
                         obj.ErrorCallback := e -> 
                         begin
                          Console.WriteLine(e.Message);
                         end;
                         obj.TraceCallback := m -> 
                         begin
                          Console.WriteLine(m);
                         end;
                         obj.Start;
                         exit obj;
                         end).As<Pipeline>().SingleInstance;
    
      builder.Register(c -> cache).As<ICache>().SingleInstance;
      
      builder.Update(existingContainer.ComponentRegistry);
    end;
    
    method ApplicationStartup(container: ILifetimeScope; pipelines: Nancy.Bootstrapper.IPipelines); override;
    begin
      inherited.ApplicationStartup(container, pipelines);
      Elmahlogging.Enable(pipelines, "elmah");
    end;
    
  public
  end;


end.
