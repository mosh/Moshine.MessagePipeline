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

    method SetDispatched(id:System.Guid);
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
        begin
          connection.Execute('update outbox set dispatched=true,dispatched_at=CURRENT_TIMESTAMP where id=@id', new class(id));
        end;

    end;

    method Store(id:System.Guid);
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
      begin
         connection.Execute("insert into outbox(id) values(@id)",new class(id));
      end;

    end;

    method TryGet(id:System.Guid):Boolean;
    begin
      using connection := new Npgsql.NpgsqlConnection(ConnectionString) do
      begin
          var count := connection.Query<Integer>('select count(*) from outbox where id=@id', new class(id)).FirstOrDefault;
          exit iif(count > 0,true,false);
      end;

    end;
  end;

end.