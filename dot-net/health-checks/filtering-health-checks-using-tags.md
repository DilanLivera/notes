# Filtering health checks using tags

By default, the health checks middleware runs all registered health checks. To run a subset of health checks, we can use the `Predicate` property of `HealthCheckOptions` class to filter a set of checks. The predicate takes a `HealthCheckRegistration` as an argument.

### Add a tag to a package from AspNetCore.Diagnostics.HealthChecks library

*Startup.cs*

```csharp
services.AddHealthChecks()
		.AddSqlServer(
			name: "SQL Server",
			connectionString: sqlServerConnection, 
			failureStatus: HealthStatus.Unhealthy
			tags: new[] { "ready" });
```

### Add a tag to a custom health check

*Startup.cs*

```csharp
services.AddHealthChecks()
		.AddCheck<DfsLocationHealthCheck>(
			name: "DFS location",
			failureStatus: HealthStatus.Unhealthy
			tags: new[] { "ready" });
```

### Filter health checks

*Startup.cs*

```csharp
app.UseEndpoints(endpoints => endpoints.MapHealthChecks(
	pattern: "/ready",
	options: new HealthCheckOptions
	{
		Predicate = healthCheckRegistration => healthCheckRegistration.Tags.Contains("ready")
	}));
```

## Resources

- [Microsoft Docs: Health checks in ASP.NET Core - Filter health checks](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks#filter-health-checks)
- [Microsoft Docs: HealthCheckOptions Class](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.diagnostics.healthchecks.healthcheckoptions)
- [Microsoft Docs: HealthCheckEndpointRouteBuilderExtensions.MapHealthChecks Method](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.healthcheckendpointroutebuilderextensions.maphealthchecks)
- [Microsoft Docs: HealthCheckRegistration Class](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.diagnostics.healthchecks.healthcheckregistration)
- [Microsoft Docs: HealthCheckRegistration.Tags Property](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.diagnostics.healthchecks.healthcheckregistration.tags)

## Tags

#health-checks #asp-dot-net-core

