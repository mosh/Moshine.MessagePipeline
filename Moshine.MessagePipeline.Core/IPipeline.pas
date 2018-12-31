namespace Moshine.MessagePipeline.Core;

uses
  System.Collections.Generic,
  System.Linq.Expressions;

type

  IPipeline = public interface

    method Initialize(parameterTypes:List<&Type>);

    method Start;

    method Send<T>(methodCall: Expression<System.Func<T,LongWord>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Word>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,ShortInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,SmallInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Single>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Double>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Integer>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Boolean>>):IResponse;
    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;

    method Stop;

    property ErrorCallback:Action<Exception>;
    property TraceCallback:Action<String>;


  end;

end.