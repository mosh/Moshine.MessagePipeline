namespace Moshine.MessagePipeline.Scope;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core;

type

  NonTransactionalScope = public class(IScope)
  private
    disposed:Boolean := false;
    property Logger: ILogger;
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

    constructor(loggerImpl:ILogger);
    begin
      Logger := loggerImpl;
    end;

    method Dispose;
    begin
      Dispose(true);
      GC.SuppressFinalize(self);
    end;

    method Complete;
    begin
      Logger.LogTrace('Complete called');
    end;

  end;

end.