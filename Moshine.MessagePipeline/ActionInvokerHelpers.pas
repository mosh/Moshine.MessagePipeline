namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  System.Linq,
  System.Threading.Tasks;

type

  ActionInvokerHelpers = public class(IActionInvokerHelpers)
  private
    property Logger: ILogger;

    _factory:IServiceFactory;
    _typeFinder:ITypeFinder;

    method FindType(typeName:String):&Type;
    begin
      Logger.LogInformation($'Finding type {typeName}');
      exit _typeFinder.FindServiceType(typeName);
    end;

  public

    constructor(factory:IServiceFactory; typeFinder:ITypeFinder; loggerImpl:ILogger);
    begin
      _factory := factory;
      _typeFinder := typeFinder;
      Logger := loggerImpl;
    end;

    method InvokeActionAsync(someAction:SavedAction):Task<Object>;
    begin

      if(not assigned(someAction))then
      begin
        Logger.LogDebug('unsigned someAction');
        raise new ApplicationException('unassigned someAction');
      end;

      Logger.LogInformation($'Invoking Method {someAction.Method} on Type {someAction.Type}');

      var someType := FindType(someAction.&Type);

      if(not assigned(someType))then
      begin
        var message := $'Type {someAction.&Type} not found';
        Logger.LogDebug(message);
        raise new Exception(message);
      end;

      Logger.LogInformation($'Found type {someAction.&Type}');

      var obj := _factory.Create(someType);

      if(not assigned(obj))then
      begin
        raise new Exception($'Service for Type {someType.Name} not implemented');
      end;

      var methodInfo := someType.GetMethod(someAction.&Method);

      if(not assigned(methodInfo))then
      begin
        var message := $'Method for Type {someType.Name} not found';
        Logger.LogDebug(message);
        raise new Exception(message);
      end;

      Logger.LogInformation($'Found method {someAction.Method} on Type {someAction.&Type}');

      if(someAction.Function)then
      begin
        Logger.LogInformation($'Method {someAction.Method} on Type {someAction.&Type} returns value');

        var invokeObj := methodInfo.Invoke(obj,someAction.Parameters.ToArray);

        if((methodInfo.ReturnType.BaseType = typeOf(Task)) or (methodInfo.ReturnType = typeOf(Task)))then
        begin
          Logger.LogInformation($'Method {someAction.Method} on Type {someAction.&Type} returns Task');

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
        Logger.LogInformation($'Method {someAction.Method} on Type {someAction.&Type} has no return value');

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