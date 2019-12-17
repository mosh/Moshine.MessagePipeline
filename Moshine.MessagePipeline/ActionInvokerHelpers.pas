namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Linq, System.Threading.Tasks;

type

  ActionInvokerHelpers = public class
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    _factory:IServiceFactory;
    _typeFinder:ITypeFinder;

    method FindType(typeName:String):&Type;
    begin
      exit _typeFinder.FindServiceType(typeName);
    end;

  public

    constructor(factory:IServiceFactory; typeFinder:ITypeFinder);
    begin
      _factory := factory;
      _typeFinder := typeFinder;
    end;

    method InvokeActionAsync(someAction:SavedAction):Task<Object>;
    begin

      if(not assigned(someAction))then
      begin
        Logger.Debug('unsigned someAction');
        raise new ApplicationException('unassigned someAction');
      end;

      var someType := FindType(someAction.&Type);

      if(not assigned(someType))then
      begin
        var message := $'Type {someAction.&Type} not found';
        Logger.Debug(message);
        raise new Exception(message);
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

        var invokeObj := methodInfo.Invoke(obj,someAction.Parameters.ToArray);

        if((methodInfo.ReturnType.BaseType = typeOf(Task)) or (methodInfo.ReturnType = typeOf(Task)))then
        begin
          var aTask:Task := Task(invokeObj);
          await aTask;

          var resultProperty := aTask.GetType.GetProperty('Result');

          if(assigned(resultProperty) and methodInfo.ReturnType.IsGenericType)then
          begin
            exit resultProperty.GetValue(aTask);
          end;
          exit nil;
        end;

        exit invokeObj;

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