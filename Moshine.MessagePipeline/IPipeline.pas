namespace Moshine.MessagePipeline;

interface

type
  IPipeline = public interface
    method Send<T>(methodCall: System.Linq.Expressions.Expression<System.Action<T>>);
    method Send<T>(methodCall: System.Linq.Expressions.Expression<System.Action<T,dynamic>>);
  end;
  
implementation

end.
