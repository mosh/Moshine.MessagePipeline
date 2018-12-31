namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IResponse = public interface
    method WaitForResultAsync(cache:ICache):Task<dynamic>;
    method WaitForResult(cache:ICache):dynamic;
    method WaitForResult<T>(cache:ICache):T;
  end;

end.