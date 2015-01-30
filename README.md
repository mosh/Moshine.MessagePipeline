Moshine.MessagePipeline
=======================

Perform asynchronous actions

Declare a service

SomeService = public class
public
  method SomeMethod;
end;

implementation

method SomeService.SomeMethod;
begin
  Console.WriteLine('Somemethod')
end;

end.

Queue up the method invocation for later processing

_pipeline.Send<SomeService>(s -> s.SomeMethod);

Developed in Oxygene using Azure ServiceBus.

Example uses Nancy and Owin to illustrated how it can be used in a Web Application.
