namespace Moshine.MessagePipeline;

uses
  Moshine.MessagePipeline.Core, System.Linq.Expressions;

type
  PipelineClient = public class(IPipelineClient)
  private

    _actionSerializer:PipelineSerializer<SavedAction>;
    _bus:IBus;
    _methodCallHelpers:MethodCallHelpers;

    method EnQueue(someAction:SavedAction);
    begin
      var stringRepresentation := _actionSerializer.Serialize(someAction);

      _bus.SendAsync(stringRepresentation, someAction.Id.ToString).Wait;

    end;

  public

    constructor(bus:IBus);
    begin
      _bus := bus;
      _methodCallHelpers := new MethodCallHelpers;

    end;

    method Send<T>(methodCall: Expression<Func<T,Boolean>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Double>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Integer>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,LongWord>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,ShortInt>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Single>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,SmallInt>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<Func<T,Word>>): IResponse;
    begin
    end;

    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        var saved := _methodCallHelpers.Save(methodCall);
        EnQueue(saved);
        exit new Response(Id:=saved.Id);
      end;
    end;

    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;
    begin
      if(assigned(methodCall))then
      begin
        var saved := _methodCallHelpers.Save(methodCall);
        EnQueue(saved);
        exit new Response(Id:=saved.Id);
      end;

    end;

  end;
end.