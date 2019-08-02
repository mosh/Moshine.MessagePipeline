namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Linq;

type

  ActionInvokerHelpers = public class
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

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
            Logger.Error(E,'Failed to find type');
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
        Logger.Debug('unsigned someAction');
        raise new ApplicationException('unassigned someAction');
      end;

      var someType := FindType(someAction.&Type);

      if(not assigned(someType))then
      begin
        var message := $'Type {someType.Name} not found';
        Logger.Debug(message);
        raise new Exception(message);
      end
      else
      begin

      end;

      var obj := _factory.Create(someType);

      if(not assigned(obj))then
      begin
        raise new Exception($'Service for Type {someType.Name} not implemented');
      end;

      Logger.Trace('InvokeAction someType.GetMethod');


      var methodInfo := someType.GetMethod(someAction.&Method);

      if(not assigned(methodInfo))then
      begin
        var message := $'Method for Type {someType.Name} not found';
        Logger.Debug(message);
        raise new Exception(message);
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