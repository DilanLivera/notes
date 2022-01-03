# Add a health check UI

## Steps

### ASP.Net Core 3.0
1. Add the [AspNetCore.HealthChecks.UI](https://www.nuget.org/packages/AspNetCore.HealthChecks.UI) package to the project.
2. Register the services used by the package in the `IServiceCollection`.
3. Add health check endpoint/s. HealthCheck UI to display health report data from our health checks; data needs to be in a specific format. For this, we need to add the `UIResponseWriter.WriteHealthCheckUIResponse` response writer to `ResponseWriter` in `HealthCheckOptions`. `WriteHealthCheckUIResponse` is defined in [AspNetCore.HealthChecks.UI.Client](https://www.nuget.org/packages/AspNetCore.HealthChecks.UI.Client/) nuget package.
4. Add `UseHealthChecksUI` middleware to the `IApplicationBuilder`. By default HealthCheck UI endpoint is `/healthchecks-ui` (eg. `https://localhost:5001/healthchecks-ui`). We can change this by setting `UIPath` property of the middleware configuration options.
5. Add the HealthCheck UI configurations to the *appsettings.json* file.
6. Go to the HealthCheck UI endpoint to see the dashboard.

*Startup.cs*

```csharp
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddHealthChecksUI();
    }

	public void Configure(IApplicationBuilder app)
	{
		app.UseRouting();

		app.UseEndpoints(endpoints => endpoints.MapHealthChecks(
			pattern: "/healthui", 
			options: new HealthCheckOptions
			{
				Predicate = _ => true
				ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
			}));

		app.UseHealthChecksUI();
	}
}
```

*appsettings.json* file

```csharp
{
  "HealthChecks-UI": {
    "EvaluationTimeInSeconds": 10, //Number of elapsed seconds between health checks.
    "HealthChecks": //The collection of health checks uris to evaluate.
	[
      {
        "Name": "Weather API", //Name of the health checks. This will show up in the dashboard.
        "Uri": "https://localhost:5001/healthui" //Health check endpoint. This should match the pattern provided in the MapHealthChecks.
      }
    ]
  }
}
```

### ASP.Net Core 6

1. Add the [AspNetCore.HealthChecks.UI](https://www.nuget.org/packages/AspNetCore.HealthChecks.UI)and [AspNetCore.HealthChecks.UI.Client](https://www.nuget.org/packages/AspNetCore.HealthChecks.UI.Client/) packages to the project.
2. Add one of the [Storage Providers](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks#ui-storage-providers) packages to the project.
3. Register the services used by the package in the `IServiceCollection`. We can configure the health check UI during the service registration.
4. Add health check endpoint/s. HealthCheck UI to display health report data from our health checks; data needs to be in a specific format. For this, we need to add the `UIResponseWriter.WriteHealthCheckUIResponse` response writer to `ResponseWriter` in `HealthCheckOptions`. `WriteHealthCheckUIResponse` is defined in [AspNetCore.HealthChecks.UI.Client](https://www.nuget.org/packages/AspNetCore.HealthChecks.UI.Client/) nuget package.
5. Add `UseHealthChecksUI` middleware to the `IApplicationBuilder`. By default HealthCheck UI endpoint is `/healthchecks-ui` (eg. `https://localhost:5001/healthchecks-ui`). We can change this by setting `UIPath` property of the middleware configuration options.
6. Add the HealthCheck UI configurations to the _appsettings.json_ file. If we configure the HealthCheck UI by code when adding `AddHealthChecksUI` to the `IServiceCollection`, we don't need to configure it in the _appsettings.json_ file. We will have the same section twice in the HealthCheck UI if we add both.
7. Go to the HealthCheck UI endpoint to see the dashboard.

*Program.cs*

```csharp
using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;

//removed for brevity

builder.Services
    .AddHealthChecks()
    .AddSqlServer(
        name: "SQL Server",
        connectionString: sqlServerConnection,
        failureStatus: HealthStatus.Unhealthy)
    .AddUrlGroup(
        name: "Weather API",
        uri: new Uri("https://localhost:5001/weatherforecast"),
        failureStatus: HealthStatus.Degraded);

builder.Services
    .AddHealthChecksUI(setupSettings =>
    {
        //This is same as confinguring using HealthChecksUI section in appsettings. We can use either or. Don't use both.
        setupSettings.AddHealthCheckEndpoint(name: "Weather App", uri: "/ready"); //We can use relative urls
        setupSettings.DisableDatabaseMigrations(); //Database Migrations are enabled by default
        setupSettings.SetEvaluationTimeInSeconds(10); //Configures the UI to poll for healthchecks
    })
    .AddInMemoryStorage();

app.MapHealthChecks(pattern: "/ready", options: new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
    Predicate = _ => true
});

app.UseHealthChecksUI(options =>
{
    options.UIPath = "/healthui";
});

//removed for brevity
```

*appsettings.json*

```json
{
  //This is same as confinguring using Settings in AddHealthChecksUI method. We can use either or. Don't use both.
  "HealthChecksUI": { //The previous configuration section was HealthChecks-UI, but due to incompatibilies with Azure Web App environment variables the section has been moved to HealthChecksUI
    "DisableMigrations": true, //Database Migrations are enabled by default
    "EvaluationTimeInSeconds": 10, //Configures the UI to poll for healthchecks
    "HealthChecks": [
      {
        "Name": "Weather API",
        "Uri": "/ready" //We can use relative urls
      }
    ]
  }
}

```


![health-check-ui](./images/health-check-ui.png)

## Resources

- [Microsoft Docs: Health monitoring - Use watchdogs](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/monitor-app-health#use-watchdogs)
- [GitHub: AspNetCore.Diagnostics.HealthChecks - HealthCheckUI](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks#healthcheckui)

## Tags

#health-checks #asp-dot-net-core
