namespace Moshine.MessagePipeline.Scope;

uses
  Moshine.MessagePipeline.Core,
  System.Transactions;

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

    method CompleteAsync:Task;
    begin
      scope.Complete;
      exit Task.CompletedTask;
    end;
  end;

end.