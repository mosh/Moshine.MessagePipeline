namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;

type

  IResponse = public interface
    method WaitForResultAsync<T>(id:Guid):Task<T>;
    method WaitForResult<T>(id:Guid):T;
  end;

end.