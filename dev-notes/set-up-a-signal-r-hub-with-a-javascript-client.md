# Set up a SignalR hub with a JavaScript client

## How to set up a Hub

- Create a Hub

  ```csharp
  using Microsoft.AspNetCore.SignalR;

  public class ViewHub : Hub
  {
      public static int ViewCounter { get; set; } = 0;

      public async Task NotifyWatchingAsync()
      {
          ViewCounter++;

          await Clients.All.SendAsync("updateViewCount", ViewCounter);
      }
  }
  ```

- Adds SignalR services to the specified `IServiceCollection`

  ```csharp
  services.AddSignalR();
  ```

- Maps incoming requests with the specified path to the specified SignalR Hub type

  ```csharp
  app.UseEndpoints(routeBuilder =>
  {
      routeBuilder.MapHub<ViewHub>("/hubs/view");
  });
  ```

## How to set up the JavaScript client

- Add `@microsoft/signalr` package

- Set up the SignalR connection

  ```javascript
  "use strict";

  let connection = new signalR.HubConnectionBuilder()
      .withUrl("/hubs/view")
      .withAutomaticReconnect()
      .build();

  connection.on(
      "updateViewCount",
      (number) => {
          var counter = document.getElementById("viewCounter");
          counter.innerText = number;
      });

  function notify() {
      connection.send("notifyWatchingAsync");
  }

  function startSuccess() {
      console.info("Connected");
      notify();
  }

  function startFail() {
      console.error("Connection failed");
  }

  connection
      .start()
      .then(startSuccess, startFail);
  ```

## Add a retry policy

```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/chathub")
    .withAutomaticReconnect({
        nextRetryDelayInMilliseconds: retryContext => {
            if (retryContext.elapsedMilliseconds < 60000) {
                return Math.random() * 10000;
            } else {
                return null;
            }
        }
    })
    .build();
```

## Conections events on the client

```javascript
connection.onreconnected(connectionId => { });

connection.onreconnecting(error => { });

connection.onclose(error => { });
```

## Connection Events on the Server

```csharp
public class ViewHub : Hub
{
    public static int ViewCount { get; set; } = 0;

    public async override Task OnConnectedAsync()
    {
        ViewCount++;

        await this.Clients.All.SendAsync("viewCountUpdate", ViewCount);

        await base.OnConnectedAsync();
    }

    public async override Task OnDisconnectedAsync(Exception exception)
    {
        ViewCount--;

        await this.Clients.All.SendAsync("viewCountUpdate", ViewCount);

        await base.OnDisconnectedAsync(exception);
    }
}
```

## Strongly typed hubs

```csharp
public interface IViewCountClient
{
    Task ViewCountUpdate(int viewCount);
}

public class ViewHub : Hub<IViewCountClient>
{
    public static int ViewCounter { get; set; } = 0;

    public async Task NotifyWatchingAsync()
    {
        ViewCounter++;

        await Clients.All.ViewCountUpdate(ViewCounter);
    }
}
```

## Credits

- [Udemy - SignalR Mastery: Become a Pro in Real-Time Web Development](https://www.udemy.com/course/signalr-mastery/)
- [ASP.NET Core SignalR JavaScript client](https://docs.microsoft.com/en-us/aspnet/core/signalr/javascript-client)

## Resources

- [Microsoft Docs - HubConnection class](https://docs.microsoft.com/en-us/javascript/api/@microsoft/signalr/hubconnection?view=signalr-js-latest)
- [ASPNet/SignalR-samples repo](https://github.com/aspnet/SignalR-samples)
