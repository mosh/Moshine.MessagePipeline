namespace TestHostConsoleApplication.Services;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Text;

type

  ServiceClass = public class
  public
    method SomeMethod;
    method SomeOtherMethod:dynamic;
    method SomeMethodWithParam(param:Object);
    method SomeMethodWithInteger(param:Integer);
  end;

implementation

method ServiceClass.SomeMethod;
begin
  Console.WriteLine('Hello World');
end;

method ServiceClass.SomeOtherMethod: dynamic;
begin
  Console.WriteLine('SomeOtherMethod');
  var obj:dynamic := new ExpandoObject;
  obj.Id := 1;
  exit obj;
end;

method ServiceClass.SomeMethodWithParam(param:Object);
begin
  Console.WriteLine('SomeMethodWithParam');
  var obj := param as dynamic;
  Console.WriteLine(obj.Id);
  Console.WriteLine(obj.Title);
end;

method ServiceClass.SomeMethodWithInteger(param:Integer);
begin
  Console.WriteLine('SomeMethodWithInteger');
end;


end.
