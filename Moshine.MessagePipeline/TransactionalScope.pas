namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core, System.Transactions;

type

  TransactionalScope = public class(IScope)
  private
    disposed:Boolean := false;
    scope:TransactionScope;

  protected

    method Dispose(disposing:Boolean);
    begin
      if(disposed)then
      begin
        exit;
      end;

      scope.Dispose;

      disposed := true;

    end;

  public

    constructor;
    begin
      scope := new TransactionScope(TransactionScopeOption.RequiresNew);

    end;


    method Dispose;
    begin
      Dispose(true);
      GC.SuppressFinalize(self);
    end;

    method Complete;
    begin
      scope.Complete;
    end;
  end;

end.