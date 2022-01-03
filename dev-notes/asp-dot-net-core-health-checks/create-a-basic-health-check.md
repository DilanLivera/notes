# Create a Basic health check

## ASP.Net Core 3.1 - 5

1. Register health check services with [AddHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.healthcheckservicecollectionextensions.addhealthchecks) in `Startup.ConfigureServices`.
2. Create a health check endpoint by calling `MapHealthChecks` in `Startup.Configure`.

*Startup.cs*

```csharp
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddHealthChecks();
    }

    public void Configure(IApplicationBuilder app)
    {
        app.UseRouting();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapHealthChecks("/health");
        });
    }
}
```

## ASP.Net Core 6

1. Register health check services with [AddHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.healthcheckservicecollectionextensions.addhealthchecks) in _Program.cs_. 
2. Create a health check endpoint by calling [MapHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.healthcheckendpointroutebuilderextensions.maphealthchecks).

*Program.cs*

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/health");

app.Run();
```

## Credits
- [Health checks in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks)

## Tags

#health-checks #asp-dot-net-core