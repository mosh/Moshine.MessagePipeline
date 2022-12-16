namespace Moshine.MessagePipeline;

uses
  Microsoft.Extensions.Logging,
  Moshine.MessagePipeline.Core,
  System.Collections.Generic,
  System.Linq,
  System.Text,
  System.Threading,
  System.Threading.Tasks;

type

  Response = public class(IResponse)
  private
    property Logger: ILogger;
    property Cache:ICache;

  public
    property MaximumWaitTimeInSeconds:Integer := 30;

    property Id:Guid;

    constructor(cacheImpl:ICache; loggerImpl:ILogger);
    begin
      Cache := cacheImpl;
      Logger := loggerImpl;
    end;

    method WaitForResultAsync<T>:Task<T>;
    begin
      Logger.LogTrace('Started WaitForResultAsync');

      var source := new CancellationTokenSource;
      var token := source.Token;

      var pollingTask := Task.Run(() ->

        begin

          var cacheResult : tuple of (Boolean,T);
          var obj:T := default(T);

          repeat
            token.ThrowIfCancellationRequested;
            cacheResult := await Cache.GetAsync<T>(Id.ToString);
            if(cacheResult.Item1)then
            begin
              obj := cacheResult.Item2;
            end;
          until (cacheResult.Item1);

          exit obj;

        end,
        token);

      var cancelTask := Task.Factory.StartNew(() ->
        begin
          Thread.Sleep(TimeSpan.FromSeconds(MaximumWaitTimeInSeconds));
          source.Cancel;
        end,
        token);

      try
        await Task.WhenAny(cancelTask,pollingTask);
      except
        on E:Exception do
          begin
            Logger.LogError(E,'Caught exception in WhenAny');
          end;
      end;

      if((pollingTask.IsCompleted) and (not pollingTask.IsCanceled) and (not pollingTask.IsFaulted))then
      begin
        Logger.LogTrace('Returning value');
        exit pollingTask.Result;
      end;
      Logger.LogTrace('Returning default');
      exit default(T);

    end;


    method WaitForResult<T>:T;
    begin
      exit WaitForResultAsync<T>.Result;
    end;


  end;

end.