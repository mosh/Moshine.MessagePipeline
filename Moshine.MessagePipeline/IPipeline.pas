namespace Moshine.MessagePipeline;

uses
  System.Linq.Expressions;

type

  IPipeline = public interface
    method Start;

    method Send<T>(methodCall: Expression<System.Func<T,LongWord>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Word>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,ShortInt>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,SmallInt>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Single>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Double>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Integer>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Boolean>>):Response;
    method Send<T>(methodCall: Expression<System.Action<T>>):Response;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):Response;

    method Stop;

  end;

end.