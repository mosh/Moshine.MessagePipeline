namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  System.Linq;

type

  ActionInvokerHelpers = public class
  private
    _factory:IServiceFactory;

    method FindType(typeName:String):&Type;
    begin

      try

        var types :=
        from a in AppDomain.CurrentDomain.GetAssemblies
        from t in a.GetTypes()
        where t.FullName = typeName
        select t;
        exit types:FirstOrDefault;
      except
        on E:Exception do
          begin
            Console.WriteLine($'Failed to find type {E.Message}');
          end;
      end;
      exit nil;
    end;

  public

    constructor(factory:IServiceFactory);
    begin
      _factory := factory;
    end;

    method InvokeAction(someAction:SavedAction):Object;
    begin

      if(not assigned(someAction))then
      begin
        raise new ApplicationException('unassigned someAction');
      end;

      var someType := FindType(someAction.&Type);

      if(not assigned(someType))then
      begin
        raise new Exception($'Type {someType.Name} not found');
      end;

      var obj := _factory.Create(someType);

      if(not assigned(obj))then
      begin
        raise new Exception($'Service for Type {someType.Name} not implemented');
      end;

      Console.WriteLine('InvokeAction someType.GetMethod');


      var methodInfo := someType.GetMethod(someAction.&Method);

      if(not assigned(methodInfo))then
      begin
        raise new Exception($'Method for Type {someType.Name} not found');
      end;

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