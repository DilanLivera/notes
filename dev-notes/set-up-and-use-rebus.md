# Set up and use Rebus

## Delete a queue automatically

```csharp
public class Startup
{
    //Revomed for brevity

    public void ConfigureServices(IServiceCollection services)
    {
        services.AddRebus((rebusConfigurer, serviceProvider) =>
            {
                var rabbitConfig = serviceProvider.GetService<IOptions<RabbitMqMessageSubscriberConfiguration>>();

                rebusConfigurer.Transport(transport =>  transport
                    .UseRabbitMq(
                    rabbitConfig.Value.RabbitSettings.ConnectionString,
                    rabbitConfig.Value.RabbitSettings.QueueName)
                    .InputQueueOptions(queueOptionsBuilder => 
                    queueOptionsBuilder.SetAutoDelete(autoDelete: true)));

                return rebusConfigurer;
            });
    }

    //Revomed for brevity
}
```

## Set the number of times to retry

When Rebus receives a message, it keeps the message's ID in an in-memory dictionary along with a few pieces of information on when the message was received, etc.

This way, Rebus can see if message delivery has failed a certain number of times (default: 5), and if the same message is received one more time, it will be considered "poisonous", and it will be forwarded to Rebus' error queue.

```csharp
using Rebus.Retry.Simple;

services.AddRebus(rebusConfigurer =>
        {
            rebusConfigurer.Options(optionsConfigurer =>
            {
                optionsConfigurer.SimpleRetryStrategy(maxDeliveryAttempts: 10);
            });

            return rebusConfigurer;
        });
```

## Change the error queue name

By default, a queue named `error` will be used and will be automatically created.

```csharp
using Rebus.Retry.Simple;

services.AddRebus(rebusConfigurer =>
        {
            rebusConfigurer.Options(optionsConfigurer =>
            {
                optionsConfigurer.SimpleRetryStrategy(errorQueueAddress: "somewhere_else");
            });

            return rebusConfigurer;
        });
```

## Enable second-level retries

To handle errors with our own logic when a message delivery has failed too many times, we can enable second-level retries.

```csharp
using Rebus.Retry.Simple;

services.AddRebus(rebusConfigurer =>
        {
            rebusConfigurer.Options(optionsConfigurer =>
            {
                optionsConfigurer.SimpleRetryStrategy(secondLevelRetriesEnabled: true);
            });

            return rebusConfigurer;
        });
```

This causes a failed message to be dispatched as a `IFailed<TMessage>()` when it has failed too many times. This way, message handlers can customize error handling like this:

```csharp
public class SomeFailedHandler : IHandleMessages<DoStuff>, IHandleMessages<IFailed<DoStuff>>
{
    readonly IBus _bus;

    public SomeHandler(IBus bus)
    {
        _bus = bus;
    }

    public async Task Handle(DoStuff message)
    {
        // do stuff that can fail here...
    }

    public async Task Handle(IFailed<DoStuff> failedMessage)
    {
        const int maxDeferCount = 5;
        var deferCount = Convert.ToInt32(message.Headers.GetValueOrDefault(Headers.DeferCount));
        if (deferCount >= maxDeferCount) 
        {
            await _bus.Advanced.TransportMessage.Deadletter($"Failed after {deferCount} deferrals\n\n{message.ErrorDescription}");

            return;
        }

        await _bus.Advanced.TransportMessage.Defer(TimeSpan.FromSeconds(30));
    }
}
```

To retry delivery after 30 seconds(customizable) when the normal delivery attempts have failed,  you can use the optional headers dictionary argument when calling the Defer method to pass along some information on how many second-level delivery attempts Rebus has made, allowing you to forward the message to the error queue if you at some point decide that something is so wrong that no further attempts should be made.

Since this is a fairly common thing to do, Rebus will automatically maintain a special header, `rbs2-defer-count` (available under the `Headers.DeferCount` key), which is set to 1, 2, 3, ... as the transport messages gets deferred. The code sample above also gives up after 5 deferrals and will send the message to the dead letter queue with a message about it having failed too many times, along with passing in the original error description.

***Please note that the transport message API (available via `bus.Advanced.TransportMessage` is used to defer the transport message in its entirety, preserving all of its original headers (including its message ID).***

## Fail fast on certain exception types

When a message handler throws an exception, Rebus will retry message delivery a couple of times(by default 5 times) before moving the message to the ***error*** queue. A downside of always retrying 5 times, is that failed messages take up a huge amount of space in our log files, because each failed delivery attempt is logged.

To help reduce the amount of noise in the logs, Rebus has the concept of ***fail fast exceptions***. An exception is considered a ***fail fast exceptions*** when Rebus' [`IFailFastChecker`](https://github.com/rebus-org/Rebus/wiki/IFailFastChecker) tells Rebus that it is so.

By default, the fail fast checker will return true for exceptions that implement `IFailFastException` (which is an empty marker interface).

```csharp
[Serializable]
public class DomainException : Exception, IFailFastException
{
    // ... exception stuff in here
}
  ```

A less intrusive way of getting Rebus to fail fast on certain exception types, is to extend the default behavior by installing a decorator. This approach is preferable when you don't want to add a reference to Rebus from the project that defines your exception type, or if it's an exception type that's defined somewhere else.

- Create a new decorator

  ```csharp
  public class MyFailFastChecker : IFailFastChecker
  {
      readonly IFailFastChecker _failFastChecker;

      public MyFailFastChecker(IFailFastChecker failFastChecker)
      {
          _failFastChecker = failFastChecker;
      }

      public bool ShouldFailFast(string messageId, Exception exception)
      {
          switch (exception)
          {
              // fail fast on our domain exception
              case DomainException _: return true;

              // fail fast if table doesn't exist, or we don't have permission
              case SqlException sqlException when sqlException.Number == 3701: return true;

              // delegate all other behavior to default
              default: return _failFastChecker.ShouldFailFast(messageId, exception);
          }
      }
  }
  ```

- Declare a new configuration extension

  ```csharp
  public static class MyFailFastCheckerConfigurationExtensions
  {
      public static void UseMyFailFastChecker(this OptionsConfigurer optionsConfigurer)
      {
          optionsConfigurer.Decorate<IFailFastChecker>(resolutionContext =>
          {
              IFailFastChecker failFastChecker = resolutionContext.Get<IFailFastChecker>();
              return new MyFailFastChecker(failFastChecker)
          });
      }
  }
  ```

- Install the decorator

  ```csharp
  services.AddRebus(rebusConfigurer =>
          {
              rebusConfigurer.Options(optionsConfigurer => 
                  optionsConfigurer.UseMyFailFastChecker());

              return rebusConfigurer;
          });
  ```

## `Rebus.Events`

Provides configuration extensions that allow for easily hooking into Rebus in various places.

  ```csharp
  using System.Diagnostics;

  services.AddRebus(rebusConfigurer =>
          {
              rebusConfigurer.Events(eventConfigurer =>
              {
                  static void SetRequestIdHandler(
                      IBus bus, 
                      Dictionary<string, string> headers, 
                      object message, 
                      IncomingStepContext context, 
                      MessageHandledEventHandlerArgs args)
                  {
                      headers.TryGetValue("RequestId", out var requestId);
                      var activity = new Activity("Audit Event");
                      activity.SetParentId(requestId);
                  }

                  eventConfigurer.BeforeMessageHandled += SetRequestIdHandler;
              });

              return rebusConfigurer;
          });
  ```

## Pipelines

- Create a step

  ```csharp
  public class LogContextProperty
  {
      public const string TransactionId = "TransactionId";
  }

  public class RebusMessageContextHeaderProperty
  {
      public const string TransactionId = "TransactionId";
  }

  public class EnrichSerilogLogContextStep : IIncomingStep
  {
      public async Task Process(IncomingStepContext context, Func<Task> next)
      {
          // We could get the properties from the message also
          //var message = context.Load<Message>();

          var transactionId = MessageContext.Current.GetHeaderPropertyValue(RebusMessageContextHeaderProperty.TransactionId);

          using (LogContext.PushProperty(LogContextProperty.TransactionId, transactionId))
          {
              await next();
          }
      }
  }
  ```

- create an extension method to decorate `IPipeline` with a `PipelineStepInjector`

  ```csharp
  public static class RebusOptionsConfigurerExtensions
  {
      public static void EnrichSerilogLogContext(this OptionsConfigurer configurer)
      {
          configurer.Decorate<IPipeline>(resolutionContext =>
          {
              IPipeline pipeline = resolutionContext.Get<IPipeline>();

              var enrichLogContextStep = new EnrichSerilogLogContextStep();

              return new PipelineStepInjector(pipeline)
                  .OnReceive(enrichLogContextStep, PipelineRelativePosition.Before, typeof(DeserializeIncomingMessageStep));
          });
      }
  }
  ```

  ```csharp
  services.AddRebus((rebusConfigurer, serviceProvider) =>
  {
      // removed for brevity

      rebusConfigurer.Options(configurer =>
      {
          // removed for brevity
          configurer.EnrichSerilogLogContext();
      });

      // removed for brevity

      return rebusConfigurer;
  });
  ```

## Warnings

- [Automatic retries and error handling (from Rebus wiki)](https://github.com/rebus-org/Rebus/wiki/Automatic-retries-and-error-handling#a-word-of-warning)

  If you configure Rebus to retry messages many times, the in-memory list of exception details could grow quite large, effectively generating the symptoms of a memory leak. Therefore, Rebus will keep at most 10 pieces of full exception details around, trimming the list of the oldest whenever a new one arrives.

  Moreover, some transports might limit the amount of information that they include in the message headers. E.g. the Azure Service Bus transport will limit the size of each header value to around 16k characters because of a limitation in the underlying transport.

## Credits

- [Rebus wiki - Fail fast on certain exception types](https://github.com/rebus-org/Rebus/wiki/Fail-fast-on-certain-exception-types)
- [Rebus wiki - Automatic retries and error handling](https://github.com/rebus-org/Rebus/wiki/Automatic-retries-and-error-handling)
- [Rebus wiki - Extensibility](https://github.com/rebus-org/Rebus/wiki/Extensibility)
