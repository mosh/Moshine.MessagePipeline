namespace Moshine.MessagePipeline.Scope;

uses
  Moshine.MessagePipeline.Core;

type

  TransactionalScopeProvider = public class(IScopeProvider)
  private
    _repository:IOutboxRepository;
  public

    constructor(repository:IOutboxRepository);
    begin
      _repository := repository;
    end;

    method Provide:IScope;
    begin
      exit new TransactionalScope(_repository);
    end;
  end;

end.