# Configure Redis Backplane for SignalR

- Install [Microsoft.AspNetCore.SignalR.StackExchangeRedis](https://www.nuget.org/packages/Microsoft.AspNetCore.SignalR.StackExchangeRedis/) package
- In the `Startup.ConfigureServices` method, call `AddStackExchangeRedis`

  ```csharp
    services.AddSignalR()
            .AddStackExchangeRedis("<your_Redis_connection_string>");
  ```

- If needed configure using `ConfigurationOptions`

  ```csharp
    services.AddSignalR()
            .AddStackExchangeRedis(
              connectionString, 
              options => {
                options.Configuration.ChannelPrefix = "MyApp";
                options.Configuration.DefaultDatabase = 5;
              });
  ```

  *Note - Options specified in `ConfigurationOptions` override the ones set in the connection string*

## Resources

- [Microsoft Docs - Set up a Redis backplane for ASP.NET Core SignalR scale-out](https://docs.microsoft.com/en-us/aspnet/core/signalr/redis-backplane)
