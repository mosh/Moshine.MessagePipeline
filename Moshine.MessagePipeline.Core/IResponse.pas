namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IResponse = public interface
    [Obsolete('Use generic version instead')]
    method WaitForResultAsync(cache:ICache):Task<dynamic>;
    method WaitForResultAsync<T>(cache:ICache):Task<T>;
    [Obsolete('Use async generic version instead')]
    method WaitForResult(cache:ICache):dynamic;
    [Obsolete('Use async version instead')]
    method WaitForResult<T>(cache:ICache):T;
  end;

end.