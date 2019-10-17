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
  public
    property Id:Guid;

    method WaitForResultAsync<T>(cache:ICache):Task<T>;
    begin

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
          Thread.Sleep(new TimeSpan(0,0,30));
          source.Cancel;
        end,
        token);

        await Task.WhenAny(cancelTask,pollingTask);

        if((pollingTask.IsCompleted) and (not pollingTask.IsCanceled) and (not pollingTask.IsFaulted))then
        begin
          exit obj;
        end;

        exit nil;
    end;



    [Obsolete('Use generic version instead')]
    method WaitForResultAsync(cache:ICache):Task<dynamic>;
    begin
      Logger.Trace('Started');

      var source := new CancellationTokenSource;
      var token := source.Token;
      var obj:Object := nil;

      var pollingTask := Task.Factory.StartNew(() ->
        begin

          repeat
            token.ThrowIfCancellationRequested;
            obj := cache.Get(Id.ToString);
            until (assigned(obj));
        end,
        token);

      var cancelTask := Task.Factory.StartNew(() ->
        begin
          Thread.Sleep(new TimeSpan(0,0,30));
          source.Cancel;
        end,
        token);

      await Task.WhenAny(cancelTask,pollingTask);

      if((pollingTask.IsCompleted) and (not pollingTask.IsCanceled) and (not pollingTask.IsFaulted))then
      begin
        exit obj;
      end;

      exit nil;

    end;

    method WaitForResult<T>(cache:ICache):T;
    begin
      Logger.Trace('Started waiting');
      var pollingTask := Task.Factory.StartNew(() ->
      begin
        var obj:T := nil;
        var startTime:=DateTime.Now;
        var difference:TimeSpan;
        repeat
          obj:=cache.Get<T>(Id.ToString);
          difference:=DateTime.Now.Subtract(startTime);
        until (assigned(obj)) or (difference.TotalSeconds > 30);

        Logger.Trace($'Returning result assigned {assigned(obj)}');

        exit obj;
      end
      );

      pollingTask.Wait;

      if(assigned(pollingTask.Result))then
      begin
        Logger.Trace($'Returning result assigned {assigned(pollingTask.Result)}');
        exit pollingTask.Result;
      end;
      Logger.Trace('Returning no result');
      exit nil;

    end;

    [Obsolete('Use generic version instead')]
    method WaitForResult(cache:ICache):dynamic;
    begin
      Logger.Trace('Started waiting');
      var pollingTask := Task.Factory.StartNew(() ->
      begin
        var obj:Object := nil;
        var startTime:=DateTime.Now;
        var difference:TimeSpan;
        repeat
          obj:=cache.Get(Id.ToString);
          difference:=DateTime.Now.Subtract(startTime);
        until (assigned(obj)) or (difference.TotalSeconds > 30);
        Logger.Trace($'Returning result assigned {assigned(obj)}');
        exit obj;
      end
      );

      pollingTask.Wait;

      if(assigned(pollingTask.Result))then
      begin
        Logger.Trace($'Returning result assigned {assigned(pollingTask.Result)}');
        exit pollingTask.Result;
      end;
      Logger.Trace('Returning no result');
      exit nil;
    end;

  end;

end.