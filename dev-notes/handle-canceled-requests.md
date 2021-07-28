# Handle Canceled Requests

## Stop asynchronous work

To stop any asynchronous work, pass the cancellation token to the task. Eg.

  ```csharp
  HttpResponseMessage responseMessage = await _client.SendAsync(
      requestMessage, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
  ```

## Stop long running work

  ```csharp
  public async Task<string> Get(CancellationToken cancellationToken)
  {
      for(var i=0; i<10; i++)
      {
          // check before each iteration starts
          cancellationToken.ThrowIfCancellationRequested();

          // slow non-cancellable work
          Thread.Sleep(1000);
      }
      
      var message = "Finished slow delay of 10 seconds.";

      _logger.LogInformation(message);

      return message;
  }
  ```

## Create a Exception filter

  ```csharp
  public class OperationCancelledExceptionFilter : IExceptionFilter
  {
      private readonly ILogger<OperationCancelledExceptionFilter> _logger;

      public OperationCancelledExceptionFilter(ILogger<OperationCancelledExceptionFilter> logger)
      {
          _logger = logger;
      }

      public void OnException(ExceptionContext context)
      {
          if (context.Exception is OperationCanceledException)
          {
              _logger.LogInformation("Request was cancelled");
              context.ExceptionHandled = true;
              // when deciding the status code to return here, be aware of the any middlewares in place to catch errors like this
              context.Result = new StatusCodeResult(400);
          }
      }
  }
  ```

## Credits

- [Using CancellationTokens in ASP.NET Core MVC controllers](https://andrewlock.net/using-cancellationtokens-in-asp-net-core-mvc-controllers/)
