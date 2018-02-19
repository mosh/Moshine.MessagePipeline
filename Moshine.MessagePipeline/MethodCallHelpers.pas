namespace Moshine.MessagePipeline;

uses
  System.Collections.Generic,
  System.Collections.ObjectModel,
  System.Linq.Expressions,
  System.Reflection;

type

  MethodCallHelpers = public class

  private

    method ArgumentsToObjectList(arguments:ReadOnlyCollection<Expression>):List<Object>;
    begin

      var objects := new List<Object>;
      for each argument in arguments do
        begin

        if(argument is ConstantExpression)then
        begin
          objects.Add(ConstantExpression(argument).Value);
        end
        else if(argument is MemberExpression)then
        begin
          var mExpression := MemberExpression(argument);


          if(mExpression.Expression is ConstantExpression)then
          begin
            var cExpression := ConstantExpression(mExpression.Expression);

            var fieldInfo := cExpression.Value.GetType().GetField(mExpression.Member.Name, BindingFlags.Instance or BindingFlags.Public or BindingFlags.NonPublic);
            var value := fieldInfo.GetValue(cExpression.Value);

            objects.Add(value);
          end
          else
          begin
            raise new ApplicationException('arguments of type '+mExpression.Expression.GetType.ToString+' not supported');
          end;

        end
        else
        begin
          raise new ApplicationException('arguments of type '+argument.GetType.ToString+' not supported');
        end;

      end;

      exit objects;

    end;


  public

    method Save<T>(methodCall: Expression<Action<T>>):SavedAction;
    begin
      var expression := MethodCallExpression(methodCall.Body);

      if not assigned(expression) then
      begin
        raise new ApplicationException('Not a static or instance method');
      end;

      var saved := new SavedAction;
      saved.&Type := expression.Method.DeclaringType.ToString;
      saved.Method := expression.Method.Name;

      saved.Parameters := ArgumentsToObjectList(expression.Arguments);

      exit saved;
    end;

    method Save<T>(methodCall: Expression<System.Func<T,Object>>):SavedAction;
    begin
      var expression := MethodCallExpression(methodCall.Body);

      if not assigned(expression) then
      begin
        raise new ApplicationException('Not a static or instance method');
      end;

      var saved := new SavedAction;
      saved.&Type := expression.Method.DeclaringType.ToString;
      saved.Method := expression.Method.Name;
      saved.Function:= true;
      saved.Parameters := ArgumentsToObjectList(expression.Arguments);

      exit saved;

    end;


  end;

end.