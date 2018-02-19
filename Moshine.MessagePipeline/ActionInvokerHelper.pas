namespace Moshine.MessagePipeline;

type

  ActionInvokerHelpers = public class
  public

    method InvokeAction(someAction:SavedAction):Object;
    begin
      var someType := FindType(someAction.&Type);

      var obj := Activator.CreateInstance(someType);
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