# What happens to a message if the handler fails to handle the message

**Message Queue** - RabbitMQ

**Service bus implementation** - Rebus

## Automatic retries and error handling

- When Rebus receives a message, it keeps the message's ID in an in-memory dictionary along with a few pieces of information on when the message was received, etc.

  This way, Rebus can see if message delivery has failed a certain number of times (default: 5), and if the same message is received one more time, it will be considered "poisonous", and it will be forwarded to Rebus' error queue.

  This way, the message is persisted to be retried at a later time.

  Change the number of retries like this

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

- During the diagnose of what went wrong,
  - Either you turn to Rebus' log - a full exception will be logged at the `WARN` level for each delivery attempt, except the last which will be logged as an `ERROR`.
  - The full exceptions will also be included in a header inside the message, allowing Rebus Snoop, or any other tool that is capable of showing message headers, to show you what went wrong.

- Rebus assumes that you want to retry delivery when it fails - and by default, it will be delivered 5 times before the message is moved to the error queue. You can configure the number of retries though.

- By default, a queue named `error` will be used and will be automatically created. This setting can be changed to use a different queue name.

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

- To handle errors with our own logic when a message delivery has failed too many times, we can enable second-level retries like this:

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

- [Word of warning (from Rebus wiki)](https://github.com/rebus-org/Rebus/wiki/Automatic-retries-and-error-handling#a-word-of-warning)

  If you configure Rebus to retry messages many times, the in-memory list of exception details could grow quite large, effectively generating the symptoms of a memory leak. Therefore, Rebus will keep at most 10 pieces of full exception details around, trimming the list of the oldest whenever a new one arrives.

  Moreover, some transports might limit the amount of information that they include in the message headers. E.g. the Azure Service Bus transport will limit the size of each header value to around 16k characters because of a limitation in the underlying transport.

## Fail fast on certain exception types

- When a message handler throws an exception, Rebus will retry message delivery a couple of times – by default 5 times – before moving the message to the ***error*** queue.

- A downside of always retrying 5 times, is that failed messages take up a huge amount of space in our log files, because each failed delivery attempt is logged.

- To help reduce the amount of noise in the logs, Rebus has the concept of ***fail fast exceptions***. An exception is considered a ***fail fast exceptions*** when Rebus' [`IFailFastChecker`](https://github.com/rebus-org/Rebus/wiki/IFailFastChecker) tells Rebus that it is so.

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

## Resources

- [Rebus wiki - Fail fast on certain exception types](https://github.com/rebus-org/Rebus/wiki/Fail-fast-on-certain-exception-types)
- [Rebus wiki - Automatic retries and error handling](https://github.com/rebus-org/Rebus/wiki/Automatic-retries-and-error-handling)
