namespace Moshine.MessagePipeline.Scope;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core;

type
  NonTransactionalScopeProvider = public class(IScopeProvider)
  private
    property logger:ILogger;

  public

    constructor(loggerImpl:ILogger);
    begin
      logger := loggerImpl;
    end;

    method Provide:IScope;
    begin
      exit new NonTransactionalScope(logger);
    end;
  end;

end.