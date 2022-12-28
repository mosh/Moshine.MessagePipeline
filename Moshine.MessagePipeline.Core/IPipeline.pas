namespace Moshine.MessagePipeline.Core;

uses
  System.Collections.Generic,
  System.Linq.Expressions, System.Threading.Tasks;

type

  IPipeline = public interface

    method StartAsync:Task;

    method SendAsync<T>(methodCall: Expression<System.Action<T>>):Task<Guid>;
    method SendAsync<T>(methodCall: Expression<System.Func<T,Object>>):Task<Guid>;

    method Version:String;

    method StopAsync:Task;

  end;

end.