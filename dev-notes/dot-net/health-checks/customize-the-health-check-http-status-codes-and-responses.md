# Customize the health check HTTP status codes and responses

We can customize the health check status codes and responses by passing a `HealthCheckOptions` to `MapHealthChecks` extension method.

### Customize the HTTP status codes

To change the mapping of `HealthStatus` to an HTTP status code applied to the response, use the `ResultStatusCodes` property of `HealthCheckOptions`.

*Startup.cs*

```csharp
app.UseEndpoints(endpoints => endpoints.MapHealthChecks(
	pattern: "/health",
	options: new HealthCheckOptions
	{
		ResultStatusCodes =
		{
			[HealthStatus.Degraded] = StatusCodes.Status500InternalServerError,
			[HealthStatus.Healthy] = StatusCodes.Status200OK,
			[HealthStatus.Unhealthy] = StatusCodes.Status503ServiceUnavailable,
		}
	}));
```

### Customize the health check response

By default, health check endpoint returns `Healthy`, `Degraded`, or `Unhealthy` responses. We can customize the response by passing a delegate to `ResponseWriter` of f `HealthCheckOptions`.

*Startup.cs*

```csharp
app.UseEndpoints(endpoints => endpoints.MapHealthChecks(
	pattern: "/health",
	options: new HealthCheckOptions
	{
		ResponseWriter = WriteHealthCheckResponseAsync
	}));
```

```csharp
private Task WriteHealthCheckResponseAsync(
	HttpContext httpContext, HealthReport healthReport)
{
	httpContext.Response.ContentType = "application/json";

	var dependencyHealthChecks = healthReport.Entries.Select(entry => new
	{
		Name = entry.Key,
		Status = entry.Value.Status.ToString(),
		DurationInSeconds = entry.Value.Duration.TotalSeconds.ToString("0:0.00"),
		Exception = entry.Value.Exception?.Message
	});

	var healthCheckResponse = new
	{
		Status = healthReport.Status.ToString(),
		TotalChecksDurationInSeconds = healthReport.TotalDuration.TotalSeconds.ToString("0:0.00"),
		DependencyHealthChecks = dependencyHealthChecks
	};

	var serializerOptions = new JsonSerializerOptions
	{
		WriteIndented = true,
		IgnoreNullValues = true,
		PropertyNamingPolicy = JsonNamingPolicy.CamelCase
	};

	var responseString = JsonSerializer.Serialize(healthCheckResponse, serializerOptions);

	return httpContext.Response.WriteAsync(responseString);
}

//sample response
/*
{
	"status": "Unhealthy",
	"totalChecksDurationInSeconds": 4.2527484,
	"dependencyHealthChecks": [
		{
			"name": "SQL Server",
			"status": "Unhealthy",
			"durationInSeconds": 0.010985,
			"exception": "A network-related or instance-specific error occurred while establishing a connection to SQL Server. The server was not found or was not accessible. Verify that the instance name is correct and that SQL Server is configured to allow remote connections. (provider: SQL Network Interfaces, error: 26 - Error Locating Server/Instance Specified)"
		}
	 ]
}
*/
```

## Resources

- [Microsoft Docs: Health checks in ASP.NET Core - Customize the HTTP status code](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks#customize-the-http-status-code)
- [Microsoft Docs: Health checks in ASP.NET Core - Customize output](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks#customize-output)
- [Microsoft Docs: HealthCheckOptions Class](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.diagnostics.healthchecks.healthcheckoptions)
- [Microsoft Docs: HealthCheckEndpointRouteBuilderExtensions.MapHealthChecks Method](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.healthcheckendpointroutebuilderextensions.maphealthchecks)

## Tags

#health-checks #asp-dot-net-core