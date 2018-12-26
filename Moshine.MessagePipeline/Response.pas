namespace Moshine.MessagePipeline;

uses
  System.Collections.Generic,
  System.Linq,
  System.Text,
  System.Threading.Tasks,
  Moshine.MessagePipeline.Core;

type
  Response = public class(IResponse)
  private
  protected
  public
    property Id:Guid;

    method WaitForResultAsync(cache:ICache):Task<dynamic>;
    begin
      var pollingTask := Task.Factory.StartNew(() ->
      begin
        var obj:Object := nil;
        var startTime:=DateTime.Now;
        var difference:TimeSpan;
        repeat
          obj:=cache.Get(Id.ToString);
          difference:=DateTime.Now.Subtract(startTime);
          until (assigned(obj)) or (difference.TotalSeconds > 30);
        exit obj;
      end
      );

      exit pollingTask;

    end;

    method WaitForResult(cache:ICache):dynamic;
    begin
      var pollingTask := Task.Factory.StartNew(() ->
      begin
        var obj:Object := nil;
        var startTime:=DateTime.Now;
        var difference:TimeSpan;
        repeat
          obj:=cache.Get(Id.ToString);
          difference:=DateTime.Now.Subtract(startTime);
          until (assigned(obj)) or (difference.TotalSeconds > 30);
        exit obj;
      end
      );

      pollingTask.Wait;

      if(assigned(pollingTask.Result))then
      begin
        exit pollingTask.Result;
      end;
      exit nil;
    end;

  end;

end.