namespace Moshine.MessagePipeline.Transports.BodyTransport;

uses
  Moshine.MessagePipeline.Core;

type
  BodyMessage = public class(IMessage)
  private
    property body:String;
  public

    constructor(messageBody:String);
    begin
      body := messageBody;
    end;

    method Clone:IMessage;
    begin
      exit new BodyMessage(body);
    end;

    method GetBody:String;
    begin
      exit body;
    end;

    method AsErrorAsync:Task;
    begin
      exit Task.CompletedTask;
    end;

    method CompleteAsync:Task;
    begin
      exit Task.CompletedTask;

    end;

  end;

end.