# Setup Serilog for centralized logging in ASP.Net Core

## How it works

We use ***ElasticSearch*** and ***Filebeat*** and ***Kibana*** to provide solution for centralized logging. Every application push log to a file or `stdout` and `Filebeat` read them and push to elastic search. By using ***Kibana*** we can then search/investigate all logs in one place. To make this work, our application needs to log in a format that is compatible with ***ElasticSearch*** and all log should have at least `TraceId` and `AppId`(This is to query by those properties in ElasticSearch when searching for logs).

## Dependencies

Nuget packages required. You can add more.

- [Serilog.AspNetCore](https://www.nuget.org/packages/Serilog.AspNetCore/)
- [Serilog.Sinks.Console](https://www.nuget.org/packages/serilog.sinks.console/)
- [Serilog.Settings.Configuration](https://www.nuget.org/packages/Serilog.Settings.Configuration/)
- [Serilog.Sinks.Async](https://www.nuget.org/packages/Serilog.Sinks.Async/)
- [Serilog.Sinks.ElasticSearch](https://www.nuget.org/packages/Serilog.Sinks.ElasticSearch/)
- [Serilog.Sinks.File](https://www.nuget.org/packages/Serilog.Sinks.File/)

## Update Program file

Update your `Program.cs`  file as below to register Serilog. Line 11 and Line 21-27 is what related to serilog. Line 11 and line 21-27 is important here to define the behavior of application log. You can add other enrichers but the one added in the code is the minimum we need for consistency.

```csharp
using System;
using System.Diagnostics;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using Serilog;

public class Program
{
    public static void Main(string[] args)
    {
        Activity.DefaultIdFormat = ActivityIdFormat.W3C;
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder
                    .UseSerilog((hostingContext, loggerConfig) =>
                    {
                        loggerConfig
                            .ReadFrom.Configuration(hostingContext.Configuration)
                            .Enrich.FromLogContext()
                            .Enrich.WithProperty("AppId", AppDomain.CurrentDomain.FriendlyName)
                            .Enrich.WithProperty("Env", hostingContext.HostingEnvironment.EnvironmentName);
                    })
                    .CaptureStartupErrors(true)
                    .UseStartup<Startup>();
            });
}
```

## Configurations in `appsettings.json` for Serilog

The `formatter` is important here. `formatter` make sure the log we pass to ElasticSearch is in friedndly format for ElasticSearch to index.

```json
{
  "Serilog": {
    "Using": [ "Serilog.Sinks.Console", "Serilog.Sinks.File", "Serilog.Sinks.Elasticsearch" ],
    "MinimumLevel": {
      "Default": "Warning",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    },
    "Enrich": [ "FromLogContext", "WithMachineName", "WithThreadId" ],
    "WriteTo": [
      {
        "Name": "Async",
        "Args": {
          "Configure": [
            {
              "Name": "Console",
              "Args": {
                "formatter": "Serilog.Formatting.Elasticsearch.ElasticsearchJsonFormatter,Serilog.Formatting.Elasticsearch"
              }
            },
            {
              "Name": "File",
              "Args": {
                "path": "./logs/app-logs.log",
                "formatter": "Serilog.Formatting.Elasticsearch.ElasticsearchJsonFormatter,Serilog.Formatting.Elasticsearch",
                "rollingInterval": "Day"
              }
            }
          ]
        }
      }
    ]
  }
}
```

## Configure Serilog for development in local machine

The JSON format of log is good for Kibana. But when you developing or debugging in your local machine you might find JSON formatted log is hard to follow in local file system because it contains lots of noise. So you can update `appsettings.Development.json` as below or use docker to setup ElasticSearch and Kibana in your local machine and directly put the log in the local ElasticSearch instance using serilog.

```json
{
    "WriteTo": [
        {
            "Name": "Async",
            "Args": {
                "Configure": [
                    {
                        "Name": "Console",
                        "Args": {
                            "outputTemplate": "{Timestamp}|{Level}|{TraceId} {Message}{NewLine:1}{Exception:1}"
                        }
                    },
                    {
                        "Name": "File",
                        "Args": {
                            "path": "./logs/app-logs.log",
                            "outputTemplate": "{Timestamp}|{Level}|{TraceId} {Message}{NewLine:1}{Exception:1}",
                            "rollingInterval": "Day"
                        }
                    }
                ]
            }
        }
    ]
}
```

## Credits

This was taken out of the *Setup Serilog for centralized logging* Confluence document created by [Mohammad Ruhul Amin](https://github.com/mruhul).
