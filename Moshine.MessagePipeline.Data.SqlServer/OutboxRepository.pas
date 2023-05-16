namespace Moshine.MessagePipeline.Data.SqlServer;

uses
  Dapper,
  Moshine.Foundation,
  Moshine.MessagePipeline.Core,
  Moshine.MessagePipeline.Core.Models,
  Microsoft.Data.SqlClient,
  System.Threading;

type
  OutboxRepository = public class(IOutboxRepository)
  private
    property Builder:IConnectionBuilder;

  public

    constructor(builderImpl:IConnectionBuilder);
    begin
      Builder := builderImpl;
    end;

    method SetDispatchedAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      using connection :=  await Builder.BuildAsync(cancellationToken) do
      begin
        await connection.ExecuteAsync('Update Outbox set Dispatched=1,DispatchedAt=CURRENT_TIMESTAMP where Id=@id', new class(id));
      end;

    end;

    method StoreAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task;
    begin
      using connection :=  await Builder.BuildAsync(cancellationToken) do
      begin
        await connection.ExecuteAsync("Insert into Outbox(Id) values(@id)",new class(id));
      end;

    end;

    method GetAsync(id:System.Guid; cancellationToken:CancellationToken := default):Task<Outbox>;
    begin
      using connection :=  await Builder.BuildAsync(cancellationToken) do
      begin
        exit (await connection.QueryAsync<Outbox>(
        'Select Id,Dispatched,DispatchedAt from Outbox where Id=@id',
        new class(id))).FirstOrDefault;
      end;

    end;

  end;

end.