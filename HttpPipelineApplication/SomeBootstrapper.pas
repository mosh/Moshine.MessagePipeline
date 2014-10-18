namespace HttpPipelineApplication;

interface

uses
  System.Collections.Generic,
  System.Configuration,
  System.Linq,
  System.Text, 
  Microsoft.WindowsAzure,
  Autofac,
  Moshine.MessagePipeline,
  Nancy, 
  Nancy.Bootstrapper,
  Nancy.Bootstrappers.Autofac,
  Nancy.Elmah,
  Nancy.TinyIoc, 
  StackExchange.Redis;

type

  SomeBootstrapper = public class(AutofacNancyBootstrapper)
  private
  protected
    method ConfigureApplicationContainer(existingContainer:ILifetimeScope);override;
    method ApplicationStartup(container: ILifetimeScope; pipelines: Nancy.Bootstrapper.IPipelines); override;
  public
  end;

implementation

method SomeBootstrapper.ConfigureApplicationContainer(existingContainer: Autofac.ILifetimeScope);
begin
  inherited.ConfigureApplicationContainer(existingContainer);

  var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');

  var cacheString := ConfigurationManager.AppSettings['RedisCache'];
  var cache := new Cache(ConnectionMultiplexer.Connect(cacheString));

  var builder := new ContainerBuilder();
  builder.Register(c -> begin
                     var obj := new Pipeline(connectionString,'TestQueue',cache);
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

  builder.Register(c -> cache).As<Cache>().SingleInstance;
  
  builder.Update(existingContainer.ComponentRegistry);
end;

method SomeBootstrapper.ApplicationStartup(container: ILifetimeScope; pipelines: Nancy.Bootstrapper.IPipelines);
begin
  inherited.ApplicationStartup(container, pipelines);
  Elmahlogging.Enable(pipelines, "elmah");
end;

end.
