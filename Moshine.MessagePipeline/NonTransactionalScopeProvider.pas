namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core;

type
  NonTransactionalScopeProvider = public class(IScopeProvider)
  private
  protected
  public
    method Provide:IScope;
    begin
      exit new NonTransactionalScope;
    end;
  end;

end.