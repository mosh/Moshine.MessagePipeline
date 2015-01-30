Moshine.MessagePipeline
=======================

Perform asynchronous actions

Declare a service

<pre><code>

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

</code></pre>

Queue up the method invocation for later processing in a controlled manner using a Queue.

<pre><code>
_pipeline.Send<SomeService>(s -> s.SomeMethod);
</code></pre>

Developed in Oxygene using Azure ServiceBus.

Example uses Nancy and Owin to illustrated how it can be used in a Web Application.
