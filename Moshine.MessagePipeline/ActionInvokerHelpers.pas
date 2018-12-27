namespace Moshine.MessagePipeline;

uses
  Autofac,
  System.Linq;

type

  ActionInvokerHelpers = public class
  private
    _scope:ILifetimeScope;

    method FindType(typeName:String):&Type;
    begin
      var types :=
      from a in AppDomain.CurrentDomain.GetAssemblies()
      from t in a.GetTypes()
      where t.FullName = typeName
      select t;
      exit types.FirstOrDefault;
    end;

  public

    constructor(scope:ILifetimeScope);
    begin
      _scope := scope;
    end;

    method InvokeAction(someAction:SavedAction):Object;
    begin

      var someType := FindType(someAction.&Type);
      var obj := _scope.Resolve(someType);

      var methodInfo := someType.GetMethod(someAction.&Method);
      if(someAction.Function)then
      begin
        exit methodInfo.Invoke(obj,someAction.Parameters.ToArray);
      end
      else
      begin
        if(someAction.Parameters.Count > 0 )then
        begin
          methodInfo.Invoke(obj,someAction.Parameters.ToArray);
        end
        else
        begin
          methodInfo.Invoke(obj,[]);
        end;

      end;


      exit nil;

    end;

  end;

end.