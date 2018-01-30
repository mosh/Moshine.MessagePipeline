Moshine.MessagePipeline
=======================

Perform asynchronous actions

Declare a service

<pre><code>

SomeService = public class
public
	method SomeMethod;
	begin
	  Console.WriteLine('Somemethod')
	end;
end;


end.

</code></pre>

Queue up the method invocation for later processing in a controlled manner using a Queue.

<pre><code>
_pipeline.Send<SomeService>(s -> s.SomeMethod);
</code></pre>

Developed in Oxygene using Azure ServiceBus or Amazon SQS.
