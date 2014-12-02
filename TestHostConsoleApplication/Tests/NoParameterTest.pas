namespace TestHostConsoleApplication.Tests;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  TestHostConsoleApplication.Services;

type
  NoParameterTest = public class(PipelineTestBase)
  private
  protected
  public
    method NoParameter;
  end;

implementation

method NoParameterTest.NoParameter;
begin
  _pipeline.Send<ServiceClass>(s -> s.SomeMethod());

end;

end.
