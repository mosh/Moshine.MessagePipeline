namespace Moshine.MessagePipeline.Core;

uses
  System.Collections.Generic,
  System.Linq.Expressions, System.Threading.Tasks;

type

  IPipeline = public interface

    method InitializeAsync:Task;

    method Start;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;

    method Version:String;

    method Stop;

  end;

end.