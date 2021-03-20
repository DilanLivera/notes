## How to use `HttpClientFactory` in .Net Core

### Named clients
```C#
    //register the client in Startup class
    public class Startup
    {
        //other properties and methods are removed for brevity

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHttpClient("GitHubClient", client =>
            {
                client.BaseAddress = new Uri("https://api.github.com/");
                client.DefaultRequestHeaders.Add("Accept", "application/vnd.github.v3+json");
                client.DefaultRequestHeaders.Add("User-Agent", "HttpClientFactoryTesting");
            });
        }
    }

    //use the client
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public ValuesController(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        [HttpGet]
        public async Task<ActionResult> Get()
        {
            var client = _httpClientFactory.CreateClient("GitHubClient");
            var result = await client.GetStringAsync("/");

            return Ok(result);
        }
    }
```

### Typed clients
```C#
    //define the client
    public class GitHubClient
    {
        public GitHubClient(HttpClient client)
        {
            Client = client;
        }

        public HttpClient Client { get; }
    }

    //register the client in Startup class
    public class Startup
    {
        //other properties and methods are removed for brevity

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHttpClient<GitHubClient>(client =>
            {
                client.BaseAddress = new Uri("https://api.github.com/");
                client.DefaultRequestHeaders.Add("Accept", "application/vnd.github.v3+json");
                client.DefaultRequestHeaders.Add("User-Agent", "HttpClientFactoryTesting");
            });
        }
    }

    //use the client
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private readonly GitHubClient _gitHubClient;

        public ValuesController(GitHubClient gitHubClient)
        {
            _gitHubClient = gitGitHubClient;
        }

        [HttpGet]
        public async Task<ActionResult> Get()
        {
            var result = await _gitHubClient.Client.GetStringAsync("/");
            return Ok(result);
        }
    }
```

### Encapsulate the `HttpClient`
```C#
    //define the client
    public interface IGitHubClient
    {
        Task<int> GetRootDataLength();
    }

    public class GitHubClient : IGitHubClient
    {
        private readonly HttpClient _client;

        public GitHubClient(HttpClient client)
        {
            _client = client;
        }

        public async Task<int> GetRootDataLength()
        {
            var data = await _client.GetStringAsync("/");
            return data.Length;
        }
    }

    //register the client in Startup class
    public class Startup
    {
        //other properties and methods are removed for brevity

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHttpClient<IGitHubClient, GitHubClient>(client =>
            {
                client.BaseAddress = new Uri("https://api.github.com/");
                client.DefaultRequestHeaders.Add("Accept", "application/vnd.github.v3+json");
                client.DefaultRequestHeaders.Add("User-Agent", "HttpClientFactoryTesting");
            });
        }
    }

    //use the client
    [Route("api/[controller]")]
    public class ValuesController : Controller
    {
        private readonly IGitHubClient _gitHubClient;

        public ValuesController(IGitHubClient gitHubClient)
        {
            _gitHubClient = gitHubClient;
        }

        [HttpGet]
        public async Task<ActionResult> Get()
        {
            var result = await _gitHubClient.GetRootDataLength();
            return Ok(result);
        }
    }
```

### Add transient fault handling with Polly
- Install the [Microsoft.Extensions.Http.Polly](https://www.nuget.org/packages/Microsoft.Extensions.Http.Polly) package
- Add a retry policy
    ```C#
        services.AddHttpClient("github")
                .AddTransientHttpErrorPolicy(policyBuilder => policyBuilder.RetryAsync(3)); //PolicyBuilder here will be preconfigured to handle HttpRequestExceptions
    ```
- Using `HttpPolicyExtensions`
    ```C#
        using Polly;

        public interface IFaultHandlingPolicy
        {
            IAsyncPolicy<HttpResponseMessage> WaitAndRetryPolicy();
        }

        using Polly;
        using Polly.Contrib.WaitAndRetry;
        using Polly.Extensions.Http;

        public class FaultHandlingPolicy : IFaultHandlingPolicy
        {
            private readonly ILogger<FaultHandlingPolicy> _logger;
            private readonly int _retryCountLimit;
            private readonly int _initialRetryDelayMilliseconds;

            public FaultHandlingPolicy(
                ILogger<FaultHandlingPolicy> logger, 
                IOptions<GitHubConfiguration> clientConfiguration)
            {
                _logger = logger;
                _retryCountLimit = clientConfiguration.Value.RetryCount;
                _initialRetryDelayMilliseconds = 
                    clientConfiguration.Value.InitialRetryDelayMilliseconds;
            }

            public IAsyncPolicy<HttpResponseMessage> WaitAndRetryPolicy()
            {
                return HttpPolicyExtensions
                    .HandleTransientHttpError()
                    .WaitAndRetryAsync(SleepDuration(), OnRetry());
            }

            private IEnumerable<TimeSpan> SleepDuration()
            {
                return Backoff.LinearBackoff(
                    TimeSpan.FromMilliseconds(_initialRetryDelayMilliseconds),
                    _retryCountLimit);
            }

            private Action<DelegateResult<HttpResponseMessage>, TimeSpan, int, Context> OnRetry()
            {
                return (result, timeSpan, currentRetryCount, context) =>
                {
                    if (result.Exception is null)
                    {
                        _logger.LogWarning(
                            "{OperationName} operation returned status code {StatusCode}. Retry {CurrentRetryCount} of {RetryCountLimit} will take place in {TotalMilliseconds} ms",
                            context.OperationKey,
                            result.Result.StatusCode,
                            currentRetryCount,
                            _retryCountLimit,
                            timeSpan.TotalMilliseconds);
                    }
                    else
                    {
                        _logger.LogWarning(
                            result.Exception,
                            "Call to {OperationName} operation resulted in exception. Retry {CurrentRetryCount} of {RetryCountLimit} will take place in {TotalMilliseconds} ms",
                            context.OperationKey,
                            currentRetryCount,
                            _retryCountLimit,
                            timeSpan.TotalMilliseconds);
                    }
                };
            }
        }

        public class Startup
        {
            //other properties and methods are removed for brevity

            public void ConfigureServices(IServiceCollection services)
            {
                services.AddHttpClient("github")
                        .AddPolicyHandler((serviceProvider, requestMessage) =>
                        {
                            IFaultHandlingPolicy policy = serviceProvider.GetService<IFaultHandlingPolicy>();
                            return policy.WaitAndRetryPolicy();
                        });
            }
        }
    ```

- Using a `PolicyRegistry`
    ```C#
        public class Startup
        {
            //other properties and methods are removed for brevity

            public void ConfigureServices(IServiceCollection services)
            {
                var timeout = Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(10));
                var longTimeout = Policy.TimeoutAsync<HttpResponseMessage>(TimeSpan.FromSeconds(30));

                var registry = services.AddPolicyRegistry();
                registry.Add("regular", timeout);
                registry.Add("long", longTimeout);

                services.AddHttpClient("github")
                        .AddPolicyHandlerFromRegistry("regular");
            }
        }
    ```

### Links
- [Steve Gordon - Introduction to HttpClientFactory ASP.Net Core series](https://www.stevejgordon.co.uk/introduction-to-httpclientfactory-aspnetcore)