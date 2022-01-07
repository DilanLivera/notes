# Add a check to test dependent API is responding normally

## Steps

1. Add [AspNetCore.HealthChecks.Uris](https://www.nuget.org/packages/AspNetCore.HealthChecks.Uris/) package to the project. This package is from  [AspNetCore.Diagnostics.HealthChecks](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks) library. By default, *AspNetCore.Diagnostics.HealthChecks* execute a `GET` operation on the endpoint we provide (Make sure to provide an endpoint that does not retrieve too much data).

2. Add the API endpoint to the `appsettings.json` file.

3. Register health check services with [AddHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.healthcheckservicecollectionextensions.addhealthchecks) in `Startup.ConfigureServices`.

4. Call the `AddUrlGroup` method with the API endpoint for the `GET` operation. By setting the `failureStatus` , we can also state the health status if this health check fails.

5. Create a health check endpoint by calling [MapHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.healthcheckendpointroutebuilderextensions.maphealthchecks).

## Code 

*appsettings.json* file

```json
{
  "WeatherApi": "https://localhost:5001/weatherforecast"
}
```

### ASP.Net Core 3.1 - 5

*Startup.cs*

```csharp
using Microsoft.Extensions.Diagnostics.HealthChecks;

public class Startup
{
	public IConfiguration Configuration { get; }

	public Startup(IConfiguration configuration)
	{
		Configuration = configuration;
	}

    public void ConfigureServices(IServiceCollection services)
    {
		string weatherApi = Configuration["WeatherApi"];
        services.AddHealthChecks()
				.AddUrlGroup(
			        name: "Weather API",
			        uri: new Uri(weatherApi),
			        failureStatus: HealthStatus.Degraded);
    }

    public void Configure(IApplicationBuilder app)
    {
        app.UseRouting();

        app.UseEndpoints(endpoints => endpoints.MapHealthChecks("/health"));
    }
}
```

### ASP.Net Core 6

*Program.cs*

```csharp
using Microsoft.Extensions.Diagnostics.HealthChecks;

WebApplicationBuilder? builder = WebApplication.CreateBuilder(args);

string? sqlServerConnection = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services
    .AddHealthChecks()
    .AddUrlGroup(
        name: "Weather API"
		uri: new Uri(weatherApi),
		failureStatus: HealthStatus.Degraded);

WebApplication? app = builder.Build();

app.MapHealthChecks("/health");

app.Run();
```

## Tags

#health-checks #asp-dot-net-core #apis
