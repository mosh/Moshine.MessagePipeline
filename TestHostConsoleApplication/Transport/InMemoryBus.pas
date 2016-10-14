namespace TestHostConsoleApplication.Tests.Transport;

uses 
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Transports.ServiceBus,
  System.Collections.Concurrent, 
  System.Threading;

type

  InMemoryMessage = public class(IMessage)
  private
    _content:String;

  public
    constructor(content:String);
    begin
      _content := content;
    end;

    property Id:String;
    property Error:Boolean;

    method AsError;
    begin
      Error := true;
    end;

    method Clone: IMessage;
    begin

      var copyOfSelf := new InMemoryMessage(_content);
      copyOfSelf.Error := self.Error;
      copyOfSelf.Id := self.Id;

      exit copyOfSelf;

    end;

    method GetBody: String;
    begin
      exit _content;
    end;

    method Complete;
    begin

    end;

  end;

  InMemoryBus = public class(IBus)
  private
    _queue : ConcurrentQueue<InMemoryMessage>;

  public
    constructor;
    begin
      _queue := new ConcurrentQueue<InMemoryMessage>;
    end;

    method Initialize;
    begin
    end;

    method Receive(serverWaitTime: TimeSpan): IMessage;
    begin
      var message : InMemoryMessage;

      if(_queue.TryDequeue(out message))then
      begin
        exit message;
      end;

      Thread.Sleep(serverWaitTime);

      if(_queue.TryDequeue(out message))then
      begin
        exit message;
      end;

      exit nil;


    end;

    method Send(message: IMessage);
    begin
      _queue.Enqueue(message as InMemoryMessage);
    end;

    method Send(messageContent: String; id: String);
    begin
      var message := new InMemoryMessage(messageContent);
      message.Id := id;

      _queue.Enqueue(message);
    end;

  end;

end.
