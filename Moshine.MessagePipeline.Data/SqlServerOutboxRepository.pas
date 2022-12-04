namespace Moshine.MessagePipeline.Data;

uses
  Dapper,
  Moshine.MessagePipeline.Core, System.Data.SqlClient;

type
  SqlServerOutboxRepository = public class(IOutbox)
  private
    property ConnectionString:String;
  public

    constructor(connectionString:String);
    begin
      self.ConnectionString := connectionString;
    end;

    method SetDispatched(id:System.Guid);
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        connection.Execute('Update Outbox set Dispatched=1,DispatchedAt=CURRENT_TIMESTAMP where Id=@id', new class(id));
      end;

    end;

    method Store(id:System.Guid);
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        connection.Execute("Insert into Outbox(Id) values(@id)",new class(id));
      end;

    end;

    method TryGet(id:System.Guid):Boolean;
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        var count := connection.Query<Integer>('Select count(*) from Outbox where Id=@id', new class(id)).FirstOrDefault;
        exit iif(count > 0,true,false);
      end;

    end;

  end;

end.