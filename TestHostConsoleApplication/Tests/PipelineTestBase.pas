namespace TestHostConsoleApplication.Tests;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  Microsoft.WindowsAzure,
  RemObjects.Elements.EUnit, 
  Moshine.MessagePipeline;

type

  PipelineTestBase = public abstract class(Test)
  protected
    _connectionString:String;
    _pipeline:IPipeline;
    _cache:ICache;
  public
    method SetupTest; override;
    method TeardownTest; override;
  end;

implementation

method PipelineTestBase.SetupTest;
begin
  _cache := new InMemoryCache;
  _connectionString := CloudConfigurationManager.GetSetting('Microsoft.ServiceBus.ConnectionString');
  _pipeline := new Pipeline(_connectionString,'pipeline',_cache);
  _pipeline.Start;
end;

method PipelineTestBase.TeardownTest;
begin
  _pipeline.Stop;
end;

end.
