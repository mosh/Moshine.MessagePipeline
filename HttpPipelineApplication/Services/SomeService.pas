namespace HttpPipelineApplication.Services;

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
    begin
      Console.WriteLine('Somemethod')
    end;
    
    method SomeMethodWithObject:dynamic;
    begin
      var obj:dynamic := new ExpandoObject;
      obj.Id := 4;
      exit obj;
    end;
    
    method CausesException:dynamic;
    begin
      raise new NotImplementedException;
    end;
    
    method SomeDomainObject(param:Object);
    begin
      var obj := param as dynamic;
      Console.WriteLine(JsonConvert.SerializeObject(obj));
    end;
    
    method SomeDomainObjectReturnsId(param:Object):dynamic;
    begin
      var dict := Dictionary<String, Object>(param);
      var obj:dynamic := new ExpandoObject;
      obj.Id := 4;
      exit obj;
    end;
    
  end;

end.
