namespace Moshine.MessagePipeline.Data;

uses
  Dapper,
  Moshine.MessagePipeline.Core;

type

  PostgresOutboxRepository = public class(IOutbox)
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

    method TryGetAsync(id:System.Guid):Task<Boolean>;
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
      begin
          var count := (await connection.QueryAsync<Integer>('select count(*) from outbox where id=@id', new class(id))).FirstOrDefault;
          exit iif(count > 0,true,false);
      end;

    end;
  end;

end.