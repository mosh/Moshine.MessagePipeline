namespace Moshine.MessagePipeline.Core;

uses
  System.Collections.Generic,
  System.Linq.Expressions, System.Threading.Tasks;

type

  IPipeline = public interface

    method InitializeAsync:Task;

    method Start;

    method Send<T>(methodCall: Expression<System.Func<T,LongWord>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Word>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,ShortInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,SmallInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Single>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Double>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Integer>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Boolean>>):IResponse;
    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;

    method Version:String;

    method Stop;

  end;

end.