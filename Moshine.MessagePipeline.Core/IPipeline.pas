namespace Moshine.MessagePipeline.Core;

uses
  System.Collections.Generic,
  System.Linq.Expressions, System.Threading.Tasks;

type

  ///
  /// Receives messages and invokes methods on classes
  ///
  IPipeline = public interface

    method StartAsync:Task;

    method Version:String;

    method StopAsync:Task;

  end;

end.