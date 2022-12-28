namespace Moshine.MessagePipeline.Data.Postgres;

uses
  Dapper,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models, System.Threading;

type

  PostgresOutboxRepository = public class(IOutboxRepository)
  private
    property Config:ISystemConfig;
  public

    constructor(config:ISystemConfig);
    begin
      self.Config := config;
    end;

    method SetDispatchedAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      using connection := new Npgsql.NpgsqlConnection(Config.DatabaseConnectionString) do
        begin
          await connection.ExecuteAsync('update outbox set dispatched=true,dispatched_at=CURRENT_TIMESTAMP where id=@id', new class(id));
        end;

    end;

    method StoreAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      using connection := new Npgsql.NpgsqlConnection(Config.DatabaseConnectionString) do
      begin
         await connection.ExecuteAsync("insert into outbox(id) values(@id)",new class(id));
      end;

    end;

    method GetAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task<Outbox>;
    begin
      using connection := new Npgsql.NpgsqlConnection(Config.DatabaseConnectionString) do
      begin
          exit (await connection.QueryAsync<Outbox>('select id, dispatched,dispatched_at as dispatchedat from outbox where id=@id', new class(id))).FirstOrDefault;
      end;

    end;
  end;

end.