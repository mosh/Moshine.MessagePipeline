namespace HttpPipelineApplication.Services;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Text;

type

  SomeService = public class
  public
    method SomeMethod;
    method SomeMethodWithObject:dynamic;
  end;

implementation

method SomeService.SomeMethod;
begin
  Console.WriteLine('Somemethod')
end;

method SomeService.SomeMethodWithObject:dynamic;
begin
  var obj:dynamic := new ExpandoObject;
  obj.Id := 4;
  exit obj;
end;

end.
