namespace HttpPipelineApplication.Services;

interface

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Text, 
  Newtonsoft.Json;

type

  SomeService = public class
  public
    method SomeMethod;
    method SomeMethodWithObject:dynamic;
    method CausesException:dynamic;
    method SomeDomainObject(param:Object);
    method SomeDomainObjectReturnsId(param:Object):dynamic;
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

method SomeService.CausesException: dynamic;
begin
  raise new NotImplementedException;
end;

method SomeService.SomeDomainObject(param: Object);
begin
  var obj := param as dynamic;
  Console.WriteLine(JsonConvert.SerializeObject(obj));
end;

method SomeService.SomeDomainObjectReturnsId(param: Object): dynamic;
begin
  var obj:dynamic := new ExpandoObject;
  obj.Id := 4;
  exit obj;
end;

end.
