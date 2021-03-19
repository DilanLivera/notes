## How to use MessagePack Hub protocol in SignalR for ASP.NET Core

### Server
- Install the [Microsoft.AspNetCore.SignalR.Protocols.MessagePack](https://www.nuget.org/packages/Microsoft.AspNetCore.SignalR.Protocols.MessagePack/)
- In the `Startup.ConfigureServices` method, add `AddMessagePackProtocol` to the `AddSignalR` call to enable MessagePack support on the server.
  ```C#
    services.AddSignalR()
            .AddMessagePackProtocol();
  ```

*Note - JSON is enabled by default. Adding MessagePack enables support for both JSON and MessagePack clients.*

### JavaScript  Client
- Install the [@microsoft/signalr-protocol-msgpack](https://www.npmjs.com/package/@microsoft/signalr-protocol-msgpack) package
- Adding `.withHubProtocol(new signalR.protocols.msgpack.MessagePackHubProtocol())` to the `HubConnectionBuilder` will configure the client to use the MessagePack protocol when connecting to a server.
  ```JS
    const connection = new signalR.HubConnectionBuilder()
        .withUrl("/chathub")
        .withHubProtocol(new signalR.protocols.msgpack.MessagePackHubProtocol())
        .build();
  ```
- When using the `<script>` element, the order is important. If `signalr-protocol-msgpack.js` is referenced before `msgpack5.js`, an error occurs when trying to connect with MessagePack. `signalr.js` is also required before `signalr-protocol-msgpack.js`.
  ```HTML
    <script src="~/lib/signalr/signalr.js"></script>
    <script src="~/lib/msgpack5/msgpack5.js"></script>
    <script src="~/lib/signalr/signalr-protocol-msgpack.js"></script>
  ```

### Links
- [MessagePack](https://msgpack.org/index.html)
- [Microsoft Docs - Use MessagePack Hub Protocol in SignalR for ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/signalr/messagepackhubprotocol)