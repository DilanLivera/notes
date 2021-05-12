# Setup Serilog With .Net Core

## Packages

- Serilog.AspNetCore
  - [NuGet package](https://www.nuget.org/packages/Serilog.AspNetCore)
  - [GitHub Repository](https://github.com/serilog/serilog-aspnetcore)

- Serilog.Sinks.File
  - [NuGet package](https://www.nuget.org/packages/Serilog.Sinks.File)
  - [GitHub Repository](https://github.com/serilog/serilog-sinks-file)

- Serilog.Sinks.Async
  - [NuGet package](https://www.nuget.org/packages/serilog.sinks.async)
  - [GitHub Repository](https://github.com/serilog/serilog-sinks-async)

- Serilog.Enrichers.Environment
  - [NuGet package](https://www.nuget.org/packages/Serilog.Enrichers.Environment)
  - [GitHub Repository](https://github.com/serilog/serilog-enrichers-environment)

- Serilog.Enrichers.Thread
  - [NuGet package](https://www.nuget.org/packages/Serilog.Enrichers.Thread)
  - [GitHub Repository](https://github.com/serilog/serilog-enrichers-thread)

- Serilog.Expressions - An embeddable mini-language for filtering, enriching, and formatting Serilog events, ideal for use with JSON or XML configuration.
  - [NuGet package](https://www.nuget.org/packages/Serilog.Expressions)
  - [GitHub Repository](https://github.com/serilog/serilog-expressions)

- Serilog.Sinks.Console - ***Note: This is included in the Serilog.AspNetCore package***
  - [NuGet package](https://www.nuget.org/packages/serilog.sinks.console)
  - [GitHub Repository](https://github.com/serilog/serilog-sinks-console)

- Serilog.Sinks.File - ***Note: This is included in the Serilog.AspNetCore package***
  - [NuGet package](https://www.nuget.org/packages/Serilog.Sinks.File)
  - [GitHub Repository](https://github.com/serilog/serilog-sinks-file)

- Serilog.Settings.Configuration - A Serilog settings provider that reads from `Microsoft.Extensions.Configuration` sources, including .NET Core's `appsettings.json` file. ***Note: This is included in the Serilog.AspNetCore package***.
  - [NuGet package](https://www.nuget.org/packages/serilog.settings.configuration)
  - [GitHub Repository](https://github.com/serilog/serilog-settings-configuration)

## Setup

  Sets Seriog as the logging provider to the host.

  ```csharp
  public class Program
  {
      public static int Main(string[] args)
      {
          //To catch and report exceptions thrown during set-up of the host
          Log.Logger = new LoggerConfiguration()
              .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
              .Enrich.FromLogContext()
              .WriteTo.Console()
              .CreateBootstrapLogger();

          try
          {
              Log.Information("Starting web host");
              CreateHostBuilder(args).Build().Run();
              return 1;
          }
          catch (Exception exception)
          {
              Log.Fatal(exception, "Host terminated unexpectedly");
              return 0;
          }
          finally
          {
              Log.CloseAndFlush();
          }
      }

      public static IHostBuilder CreateHostBuilder(string[] args)
      {
          return Host.CreateDefaultBuilder(args)
              .UseSerilog(SetupSerilog)
              .ConfigureWebHostDefaults(webBuilder =>
              {
                  webBuilder.UseStartup<Startup>();
              });
      }

      public static void SetupSerilog(
          HostBuilderContext context, 
          IServiceProvider serviceProvider, 
          LoggerConfiguration loggerConfiguration)
      {
          loggerConfiguration
              .ReadFrom.Configuration(context.Configuration)
              .ReadFrom.Services(serviceProvider)
              .Enrich.WithThreadId()
              .Enrich.WithMachineName()
              .Enrich.FromLogContext()
              .WriteTo.Debug()
              .WriteTo.Console(
                  outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}",
                  theme: AnsiConsoleTheme.Code)
              .WriteTo.Async(ConfigureAsyncWrapper);
      }

      public static void ConfigureAsyncWrapper(LoggerSinkConfiguration loggerSinkConfiguration)
      {
          loggerSinkConfiguration.File(
              formatter: new CompactJsonFormatter(),
              path: "logs/log.txt",
              rollingInterval: RollingInterval.Day,
              buffered: true);
      }
  }
  ```

  Add the Serilog configuration to the `appsettings.json` file. This is not necessary.

  ```json
  {
    "Serilog": {
      "MinimumLevel": {
        "Default": "Information",
        "Override": {
          "Microsoft": "Warning",
          "Microsoft.Hosting.Lifetime": "Information"
        }
      }
    }
  }
  ```

  Add `UseSerilogRequestLogging` to middleware pipeline to add request logging. For more information goto [Serilog.AspNetCore - Request logging](https://github.com/serilog/serilog-aspnetcore#request-logging).

  ```csharp
  public class Startup
  {
      public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
      {
          if (env.IsDevelopment())
          {
              app.UseDeveloperExceptionPage();
          }

          /*
            * It is important that this appears before handlers such as MVC. 
            * The middleware will not time or log components that appear before it in the pipeline
            */
          app.UseSerilogRequestLogging(ConfigureSerilogRequestLogging);

          app.UseHttpsRedirection();

          app.UseRouting();

          app.UseAuthorization();

          app.UseEndpoints(endpoints =>
          {
              endpoints.MapControllers();
          });
      }

      public void ConfigureSerilogRequestLogging(RequestLoggingOptions options)
      {
          // Attach additional properties to the request completion event
          options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
          {
              diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
              diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
          };
      }
  }
  ```

## Resources

- [Serilog Wiki](https://github.com/serilog/serilog/wiki)
