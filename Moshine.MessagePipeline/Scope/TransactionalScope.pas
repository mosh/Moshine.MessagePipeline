namespace Moshine.MessagePipeline.Scope;

uses
  Moshine.MessagePipeline.Core,
  System.Transactions;

type

  TransactionalScope = public class(IScope)
  private
    disposed:Boolean := false;
    scope:TransactionScope;
    _repository:IOutboxRepository;

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

    constructor(repository:IOutboxRepository);
    begin
      scope := new TransactionScope(TransactionScopeOption.RequiresNew, TransactionScopeAsyncFlowOption.Enabled);
      _repository := repository;
    end;


    method Dispose;
    begin
      Dispose(true);
      GC.SuppressFinalize(self);
    end;

    method CompleteAsync(scopeId:Guid):Task;
    begin
      await _repository.StoreAsync(scopeId);
      scope.Complete;
    end;
  end;

end.