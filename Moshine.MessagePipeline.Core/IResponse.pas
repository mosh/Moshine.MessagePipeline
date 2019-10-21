namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IResponse = public interface
    method WaitForResultAsync<T>(cache:ICache):Task<T>;
    method WaitForResult<T>(cache:ICache):T;
  end;

end.