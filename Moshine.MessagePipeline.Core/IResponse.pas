namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IResponse = public interface
    method WaitForResultAsync<T>:Task<T>;
    method WaitForResult<T>:T;
  end;

end.