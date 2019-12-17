namespace Moshine.MessagePipeline.Scope;

uses
  Moshine.MessagePipeline.Core;

type
  TransactionalScopeProvider = public class(IScopeProvider)
  private
  protected
  public
    method Provide:IScope;
    begin
      exit new TransactionalScope;
    end;
  end;

end.