namespace TestHostConsoleApplication.Tests;


uses
  System.Collections.Generic,
  System.Linq,
  System.Text, 
  RemObjects.Elements.EUnit, 
  Moshine.MessagePipeline;

type
  SerializerTests = public class(Test)
  private
  protected
  public

    method DomainObject;
    begin
        var obj:dynamic := new DynamicDomainObject;
        obj.Id := 4;
        obj.Name := 'RedisCache';
    
        var action := new SavedAction;
        action.Id := Guid.NewGuid;
        action.Method:='SomeMethod';
        action.Parameters := new List<Object>;
        action.Parameters.Add(obj);
    
        var objAsString := PipelineSerializer.Serialize(action);
    
        var savedAction := PipelineSerializer.Deserialize<SavedAction>(objAsString);
    
    end;

    method DomainObjectWithList;
    begin
      var someList := new List<Integer>;
      someList.Add(1);
      someList.Add(4);
      var obj:dynamic := new DynamicDomainObject;
      obj.Id := 4;
      obj.Name := 'RedisCache';
      obj.SomeList := someList;
    
      var action := new SavedAction;
      action.Id := Guid.NewGuid;
      action.Method:='SomeMethod';
      action.Parameters := new List<Object>;
      action.Parameters.Add(obj);
    
      var objAsString := PipelineSerializer.Serialize(action);
    
      var savedAction := PipelineSerializer.Deserialize<SavedAction>(objAsString);
    
      Assert.IsTrue(savedAction.Parameters.Count = 1);
      var param:dynamic := savedAction.Parameters.First;
      Assert.IsTrue(Integer(param.Id) = 4);
      Assert.IsTrue(String(param.Name) = 'RedisCache');
      var newList:List<Integer>:=param.SomeList;
      Assert.IsTrue(newList.Count = someList.Count);
      Assert.IsTrue(newList[0] = 1);
      Assert.IsTrue(newList[1] = 4);
    end;
  end;


end.
