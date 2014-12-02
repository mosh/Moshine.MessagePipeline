namespace TestHostConsoleApplication.Tests;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  Moshine.MessagePipeline, 
  TestHostConsoleApplication.Services;

type
  DomainObjectTest = public class(PipelineTestBase)
  private
  protected
  public
    method DomainObjectParameter();
  end;

implementation

method DomainObjectTest.DomainObjectParameter;
begin
  var obj:dynamic := new DynamicDomainObject;
  obj.Id := 1;
  obj.Title := 'John Smith';

  var obj2:Object := obj;	
  _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithParam(obj2));

end;

end.
