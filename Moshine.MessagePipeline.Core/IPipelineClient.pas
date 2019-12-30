namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core,
  System.Linq.Expressions,
  System.Collections.Generic,
  System.Threading.Tasks;

type
  IPipelineClient = public interface

    method InitializeAsync:Task;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<IResponse>;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;

  end;
end.