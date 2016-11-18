namespace TestHostConsoleApplication.Services;

uses
  System.Collections.Generic,
  System.Dynamic,
  System.Linq,
  System.Text, 
  System.Threading;

type

  ServiceExecuted = public static class

  public

    Bouncer:Semaphore; 

    method Init;
    begin
      if(assigned(Bouncer))then
      begin
        raise new ApplicationException('Already in progress');
      end;
      Bouncer := new Semaphore(1, 1);
      Bouncer.WaitOne;
    end;

    method Done;
    begin
      if(assigned(Bouncer))then
      begin
        Bouncer.Release;
      end;

    end;

    method Wait;
    begin
      if(assigned(Bouncer))then
      begin
        Bouncer.WaitOne;
        Bouncer.Release;
      end;
      Bouncer := nil;

    end;
  end;

  Employee = public class
  public
    property Id:Integer;
    property Name:String;
  end;

  ServiceClass = public class
  public
    method SomeMethod;
    begin
      Console.WriteLine('Hello World');
      ServiceExecuted.Done;
    end;

    method SomeOtherMethod:dynamic;
    begin
      Console.WriteLine('SomeOtherMethod');
      var obj:dynamic := new ExpandoObject;
      obj.Id := 1;
      ServiceExecuted.Done;
      exit obj;
    end;

    method SomeMethodWithParam(param:Object);
    begin
      Console.WriteLine('SomeMethodWithParam');
      var obj := param as dynamic;
      Console.WriteLine(obj.Id);
      Console.WriteLine(obj.Title);
      ServiceExecuted.Done;
    end;

    method SomeMethodWithInteger(param:Integer);
    begin
      Console.WriteLine('SomeMethodWithInteger');
      Console.WriteLine(param);
      ServiceExecuted.Done;
    end;

    method DisplayEmployee(e:Employee);
    begin
      Console.WriteLine('{0} {1}',e.Id, e.Name);
      ServiceExecuted.Done;
    end;

    method SomeMethodWithObject:dynamic;
    begin
      var obj:dynamic := new ExpandoObject;
      obj.Id := 4;
      ServiceExecuted.Done;
      exit obj;
    end;

    method SomeMethodWithIntegerParams(oneParam:Integer; twoParam:Integer; threeParam:INteger);
    begin
      Console.WriteLine('{0} {1} {2}',oneParam, twoParam, threeParam);
      ServiceExecuted.Done;
    end;

  end;

end.
