namespace Moshine.MessagePipeline.Core;

uses
  System.Threading.Tasks;
type

  IMessage = public interface
    method Clone:IMessage;
    method GetBody:String;
    method AsErrorAsync:Task;
    method CompleteAsync:Task;
  end;

end.