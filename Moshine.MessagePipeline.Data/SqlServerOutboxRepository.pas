namespace Moshine.MessagePipeline.Data;

uses
  Dapper,
  Moshine.MessagePipeline.Core, System.Data.SqlClient, Moshine.MessagePipeline.Core.Models;

type
  SqlServerOutboxRepository = public class(IOutbox)
  private
    property ConnectionString:String;
  public

    constructor(connectionString:String);
    begin
      self.ConnectionString := connectionString;
    end;

    method SetDispatchedAsync(id:System.Guid):Task;
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        await connection.ExecuteAsync('Update Outbox set Dispatched=1,DispatchedAt=CURRENT_TIMESTAMP where Id=@id', new class(id));
      end;

    end;

    method StoreAsync(id:System.Guid):Task;
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        await connection.ExecuteAsync("Insert into Outbox(Id) values(@id)",new class(id));
      end;

    end;

    method GetAsync(id:System.Guid):Task<Outbox>;
    begin
      using connection := new SqlConnection(ConnectionString) do
      begin
        exit (await connection.QueryAsync<Outbox>('Select Id,Dispatched,DispatchedAt from Outbox where Id=@id', new class(id))).FirstOrDefault;
      end;

    end;

  end;

end.