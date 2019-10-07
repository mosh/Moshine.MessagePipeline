﻿namespace Moshine.MessagePipeline.Core;

uses
  Moshine.MessagePipeline.Core, System.Linq.Expressions, System.Collections.Generic;

type
  IPipelineClient = public interface

    method Initialize(parameterTypes:List<&Type>);

    method Send<T>(methodCall: Expression<System.Func<T,LongWord>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Word>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,ShortInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,SmallInt>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Single>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Double>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Integer>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Boolean>>):IResponse;
    method Send<T>(methodCall: Expression<System.Action<T>>):IResponse;
    method Send<T>(methodCall: Expression<System.Func<T,Object>>):IResponse;

  end;
end.