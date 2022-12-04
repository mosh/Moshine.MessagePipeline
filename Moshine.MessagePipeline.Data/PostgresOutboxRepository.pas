namespace Moshine.MessagePipeline.Data;

uses
  Dapper,
  Moshine.MessagePipeline.Core, Moshine.MessagePipeline.Core.Models;

type

  PostgresOutboxRepository = public class(IOutboxRepository)
  private
    property ConnectionString:String;
  public

    constructor(connectionString:String);
    begin
      self.ConnectionString := connectionString;
    end;

    method SetDispatchedAsync(id:System.Guid):Task;
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
        begin
          await connection.ExecuteAsync('update outbox set dispatched=true,dispatched_at=CURRENT_TIMESTAMP where id=@id', new class(id));
        end;

    end;

    method StoreAsync(id:System.Guid):Task;
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
      begin
         await connection.ExecuteAsync("insert into outbox(id) values(@id)",new class(id));
      end;

    end;

    method GetAsync(id:System.Guid):Task<Outbox>;
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
      begin
          exit (await connection.QueryAsync<Outbox>('select id, dispatched,dispatched_at as dispatchedat from outbox where id=@id', new class(id))).FirstOrDefault;
      end;

    end;
  end;

end.