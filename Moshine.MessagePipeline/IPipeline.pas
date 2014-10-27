namespace Moshine.MessagePipeline;

interface

uses
  System.Linq.Expressions;

type
  IPipeline = public interface
    method Send<T>(methodCall: Expression<System.Action<T>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):Response;
  end;
  
implementation

end.
