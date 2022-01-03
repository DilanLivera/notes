# Create a middleware to enrich Serilog `LogContext` with correlation properties

## Convention based middleware

```csharp
using System.Linq;
using System.Threading.Tasks;
using Application.Core.Constants;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;
using Serilog.Context;

public class SerilogLogContextEnrichMiddleware
{
    private readonly RequestDelegate _next;

    public SerilogLogContextEnrichMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        var transactionId = GetFirstOrDefaultHeaderValue(
            context.Request.Headers,
            HeaderParameter.TransactionId);
        var userId = GetFirstOrDefaultHeaderValue(
            context.Request.Headers,
            HeaderParameter.UserId);

        using (LogContext.PushProperty(LogContextProperty.TransactionId, transactionId))
        using (LogContext.PushProperty(LogContextProperty.UserId, userId))
        {
            await _next(context);
        }
    }

    private string GetFirstOrDefaultHeaderValue(IHeaderDictionary headers, string headerKey)
    {
        if(headers is null)
        {
            return null;
        }

        if(headers.TryGetValue(headerKey, out StringValues headerValues))
        {
            return headerValues.ToList().FirstOrDefault()?.ToString();
        }

        return null;
    }
}
```

```csharp
using Application.Core.Middleware;
using Microsoft.AspNetCore.Builder;

public static class MiddlewareExtensions
{
    public static IApplicationBuilder UseSerilogLogContextEnrichMiddleware(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<SerilogLogContextEnrichMiddleware>();
    }
}
```

```csharp
using Application.Core.Extensions;
using Microsoft.AspNetCore.Builder;
using Serilog;

public class Startup
{
    // removed for brevity

    public void Configure(IApplicationBuilder app)
    {
        app.UseSerilogRequestLogging();

        // position of the middleware matters
        app.UseSerilogLogContextEnrichMiddleware();

        app.UseRouting();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
```

## Add correlation properties to request completion event by Serilog

```csharp
using System.Linq;
using System.Threading.Tasks;
using Application.Core.Constants;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Primitives;
using Serilog;
using Serilog.Context;

public class SerilogLogContextEnrichMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IDiagnosticContext _diagnosticContext;

    public SerilogLogContextEnrichMiddleware(
        RequestDelegate next,
        IDiagnosticContext diagnosticContext)
    {
        _next = next;
        _diagnosticContext = diagnosticContext;
    }

    public async Task Invoke(HttpContext context)
    {
        var transactionId = GetFirstOrDefaultHeaderValue(
            context.Request.Headers, HeaderParameter.TransactionId);
        var userId = GetFirstOrDefaultHeaderValue(
            context.Request.Headers, HeaderParameter.UserId);

        // this will add the correlation properties to request completion event
        // they will be included in the log statement by UseSerilogRequestLogging middleware
        _diagnosticContext.Set(LogContextProperty.TransactionId, transactionId);
        _diagnosticContext.Set(LogContextProperty.UserId, userId);

        using (LogContext.PushProperty(LogContextProperty.TransactionId, transactionId))
        using (LogContext.PushProperty(LogContextProperty.UserId, userId))
        {
            await _next(context);
        }
    }

    private string GetFirstOrDefaultHeaderValue(IHeaderDictionary headers, string headerKey)
    {
        if(headers is null)
        {
            return null;
        }

        if(headers.TryGetValue(headerKey, out StringValues headerValues))
        {
            return headerValues.ToList().FirstOrDefault()?.ToString();
        }

        return null;
    }
}
```

## Resources

- [Write custom ASP.NET Core middleware](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/write)
- [Factory-based middleware activation in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/extensibility)
- [Test ASP.NET Core middleware](https://docs.microsoft.com/en-us/aspnet/core/test/middleware)
- [ASP.NET Core MVC and `UseSerilogRequestLogging()`](https://nblumhardt.com/2019/10/serilog-mvc-logging/)
- [Serilog.AspNetCore](https://github.com/serilog/serilog-aspnetcore)
