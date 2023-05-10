namespace Moshine.MessagePipeline.Data.Postgres;

uses
  Dapper,
  Microsoft.Extensions.Logging,
  Moshine.Foundation,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models, System.Threading;

type

  OutboxRepository = public class(IOutboxRepository)
  private
    property Builder:IConnectionBuilder;
    property Logger:ILogger;
  public

    constructor(builderImpl:IConnectionBuilder; loggerImpl:ILogger<OutboxRepository>);
    begin
      Builder := builderImpl;
      Logger := loggerImpl;
      if(not assigned(Builder))then
      begin
        raise new ArgumentNullException(nameOf(Builder));
      end;
    end;

    method SetDispatchedAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('SetDispatchedAsync');
      using connection := await Builder.BuildAsync(cancellationToken) do
        begin
          await connection.ExecuteAsync('update outbox set dispatched=true,dispatched_at=CURRENT_TIMESTAMP where id=@id',
                                        new class(id));
        end;
    end;

    method StoreAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      Logger.LogInformation('StoreAsync');
      using connection := await Builder.BuildAsync(cancellationToken) do
      begin
         await connection.ExecuteAsync("insert into outbox(id) values(@id)",new class(id));
      end;

    end;

    method GetAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task<Outbox>;
    begin
      Logger.LogInformation('GetAsync');
      using connection := await Builder.BuildAsync(cancellationToken) do
      begin
          exit (await connection.QueryAsync<Outbox>('select id, dispatched,dispatched_at as dispatchedat from outbox where id=@id', new class(id))).FirstOrDefault;
      end;

    end;
  end;

end.