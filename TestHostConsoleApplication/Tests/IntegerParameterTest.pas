namespace TestHostConsoleApplication.Tests;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  TestHostConsoleApplication.Services;

type
  IntegerParameterTest = public class(PipelineTestBase)
  private
  protected
  public
    method IntegerParameterTest;
  end;

implementation

method IntegerParameterTest.IntegerParameterTest;
begin
  _pipeline.Send<ServiceClass>(s -> s.SomeMethodWithInteger(4));
end;

end.
