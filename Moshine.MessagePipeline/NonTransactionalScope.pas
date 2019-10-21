namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core, NLog;

type

  NonTransactionalScope = public class(IScope)
  private
    disposed:Boolean := false;
    class property Logger: Logger := LogManager.GetCurrentClassLogger;
  protected

    method Dispose(disposing:Boolean);
    begin
      if(disposed)then
      begin
        exit;
      end;

      disposed := true;

    end;

  public

    constructor;
    begin

    end;

    method Dispose;
    begin
      Dispose(true);
      GC.SuppressFinalize(self);
    end;

    method Complete;
    begin
      Logger.Info('Complete called');
    end;

  end;

end.