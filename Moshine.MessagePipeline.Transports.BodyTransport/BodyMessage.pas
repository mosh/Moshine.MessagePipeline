namespace Moshine.MessagePipeline.Transports.BodyTransport;

uses
  Moshine.MessagePipeline.Core, System.Threading;

type

  BodyMessage = public class(IMessage)
  private
    property body:String;
    property messageId:Guid;
  public

    assembly constructor(messageBody:String; messageId:Guid);
    begin
      body := messageBody;
      self.messageId:=messageId;
    end;

    method Clone:IMessage;
    begin
      exit new BodyMessage(body,messageId);
    end;

    method GetBody:String;
    begin
      exit body;
    end;

    method AsErrorAsync(cancellationToken:CancellationToken := default):Task;
    begin
      exit Task.CompletedTask;
    end;

    method CompleteAsync(cancellationToken:CancellationToken := default):Task;
    begin
      exit Task.CompletedTask;
    end;

    property Id:Guid read
      begin
        exit messageId;
      end;

  end;

end.