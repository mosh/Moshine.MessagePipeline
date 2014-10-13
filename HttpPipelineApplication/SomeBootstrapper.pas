namespace HttpPipelineApplication;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  Microsoft.WindowsAzure,
  Autofac,
  Moshine.MessagePipeline,
  Nancy, 
  Nancy.Bootstrappers.Autofac,
  Nancy.TinyIoc;

type

  SomeBootstrapper = public class(AutofacNancyBootstrapper)
  private
  protected
    method ConfigureApplicationContainer(existingContainer:ILifetimeScope);override;
  public
  end;

implementation

method SomeBootstrapper.ConfigureApplicationContainer(existingContainer: Autofac.ILifetimeScope);
begin
  inherited.ConfigureApplicationContainer(existingContainer);

  var connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');

  var builder := new ContainerBuilder();
  builder.Register(c -> begin
                     var obj := new Pipeline(connectionString,'TestQueue');
                     obj.Start;
                     exit obj;
                     end).As<Pipeline>().SingleInstance;
  
  builder.Update(existingContainer.ComponentRegistry);
end;

end.
