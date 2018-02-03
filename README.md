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

      var bus := new AmazonSQSBus (..);
      or
      var bus := new ServiceBus(...);
      
      var cache:ICache := new InMemoryCache;
      var pipe := new Pipeline(cache, bus);

      pipe.TraceCallback := method(message:String) begin
        Console.WriteLine('trace '+message);
      end;

      pipe.ErrorCallback := method(e:Exception) begin
        Console.writeLine('Exception '+e.Message);
      end;

      pipe.Start;

      var pipelineResponse:=pipe.Send<SomeService>(s -> s.SomeMethodWithObject);
      var obj:Object:=pipelineResponse.WaitForResult(cache);

</code></pre>

Developed in Oxygene using Azure ServiceBus or Amazon SQS.
