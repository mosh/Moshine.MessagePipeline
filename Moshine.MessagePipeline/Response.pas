namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core,
  NLog,
  System.Collections.Generic,
  System.Linq,
  System.Text,
  System.Threading.Tasks;

type
  Response = public class(IResponse)
  private
    class property Logger: Logger := LogManager.GetCurrentClassLogger;
  public
    property Id:Guid;

    method WaitForResultAsync(cache:ICache):Task<dynamic>;
    begin
      Logger.Trace('Started');
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

      exit pollingTask;

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