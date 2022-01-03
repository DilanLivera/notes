# Add a check to test dependent database is responding normally

## Steps

1. Add [AspNetCore.HealthChecks.SqlServer](https://www.nuget.org/packages/AspNetCore.HealthChecks.SqlServer) package to the project. This package is from  [AspNetCore.Diagnostics.HealthChecks](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks) library. *AspNetCore.Diagnostics.HealthChecks* executes a `SELECT 1` query against the database to confirm the connection to the database is healthy. Please select the appropriate package for your database service from *AspNetCore.Diagnostics.HealthChecks* library. Please find a list of services HealthChecks packages include health checks for [here](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks#health-checks)

2. Add a valid database connection string in the `appsettings.json` file.

3. Register health check services with [AddHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.extensions.dependencyinjection.healthcheckservicecollectionextensions.addhealthchecks) in `Startup.ConfigureServices`.

4. Call the `AddSqlServer` method with the database connection string. By setting the `failureStatus` , we can also state the health status if this health check fails.

5. Create a health check endpoint by calling [MapHealthChecks](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.builder.healthcheckendpointroutebuilderextensions.maphealthchecks). 

## Code 

*appsettings.json* file

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;Connect Timeout=30"
  }
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
		string sqlServerConnection = Configuration["ConnectionStrings:DefaultConnection"];
        services.AddHealthChecks()
				.AddSqlServer(
					name: "SQL Server",
					connectionString: sqlServerConnection, 
					failureStatus: HealthStatus.Unhealthy);
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
    .AddSqlServer(
		name: "SQL Server",
		connectionString: sqlServerConnection, 
		failureStatus: HealthStatus.Unhealthy);

WebApplication? app = builder.Build();

app.MapHealthChecks("/health");

app.Run();
```

## Credits

- [Health checks in ASP.NET Core - Database probe](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks#database-probe)

## Tags

#health-checks #asp-dot-net-core #database