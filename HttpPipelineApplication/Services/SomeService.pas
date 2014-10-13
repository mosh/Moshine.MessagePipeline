namespace HttpPipelineApplication.Services;

interface

uses
  System.Collections.Generic,
  System.Linq,
  System.Text;

type

  SomeService = public class
  public
    method SomeMethod;
  end;

implementation

method SomeService.SomeMethod;
begin
  Console.WriteLine('Somemethod')
end;

end.
