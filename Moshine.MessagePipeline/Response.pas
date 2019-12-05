namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Collections.Generic,
  System.Linq,
  System.Text,
  System.Threading,
  System.Threading.Tasks;

type
  Response = public class(IResponse)
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;

    property cache:ICache;
  public
    property MaximumWaitTimeInSeconds:Integer := 30;

    property Id:Guid;

    constructor(cacheImpl:ICache);
    begin
      cache := cacheImpl;
    end;

    method WaitForResultAsync<T>:Task<T>;
    begin
      Logger.Trace('Started');

      var source := new CancellationTokenSource;
      var token := source.Token;
      var obj:T := nil;

      var pollingTask := Task.Factory.StartNew(() ->
        begin

          repeat
            token.ThrowIfCancellationRequested;
            obj := cache.Get<T>(Id.ToString);
          until (assigned(obj));
        end,
        token);

      var cancelTask := Task.Factory.StartNew(() ->
        begin
          Thread.Sleep(new TimeSpan(0,0,MaximumWaitTimeInSeconds));
          source.Cancel;
        end,
        token);

        try
          await Task.WhenAny(cancelTask,pollingTask);
        except
          on E:Exception do
            begin
              Logger.Trace('Caught exception in WhenAny');
            end;
        end;

        if((pollingTask.IsCompleted) and (not pollingTask.IsCanceled) and (not pollingTask.IsFaulted))then
        begin
          Logger.Trace('Returning value');
          exit obj;
        end;
        Logger.Trace('Returning nil');
        exit nil;
    end;


    method WaitForResult<T>:T;
    begin
      exit WaitForResultAsync<T>.Result;
    end;


  end;

end.