# Get all application configuration settings of an ASP.Net Core web application

```csharp
public void Configure(IApplicationBuilder app)
{
    app.UseRouting();

    app.UseEndpoints(endpoints =>
    {
        endpoints.MapControllers();
        endpoints.MapHealthChecks("/health");
        endpoints.MapGet("/dump-config", async context =>
        {
            var configInfo = (Configuration as IConfigurationRoot).GetDebugView();
            await context.Response.WriteAsync(configInfo);
        });
    });
}
```
