# Get the user secrets from secrets.json file if the environment is not Development

The user secrets configuration source is automatically added in Development mode when the project calls `CreateDefaultBuilder`. `CreateDefaultBuilder` calls `AddUserSecrets` when the `EnvironmentName` is `Development`.

- If the `EnvironmentName` is not `Development`

    ```csharp
        public class Program
        {
            public static void Main(string[] args)
            {
                CreateHostBuilder(args).Build().Run();
            }

            public static IHostBuilder CreateHostBuilder(string[] args)
            {
                return Host
                    .CreateDefaultBuilder(args)
                    .ConfigureAppConfiguration((hostContext, builder) =>
                    {
                        if (hostContext.HostingEnvironment.EnvironmentName.Equals(
                            "LocalDevelopment", 
                            StringComparison.OrdinalIgnoreCase))
                        {
                            builder.AddUserSecrets<Program>();
                        }
                    })
                    .ConfigureWebHostDefaults(webBuilder =>
                    {
                        webBuilder.UseStartup<Startup>();
                    });
            }
        }
    ```

- When `CreateDefaultBuilder` isn't called

    ```csharp
        public class Program
        {
            public static void Main(string[] args)
            {
                var host = new HostBuilder()
                    .ConfigureAppConfiguration((hostContext, builder) =>
                    {
                        if (hostContext.HostingEnvironment.IsDevelopment())
                        {
                            builder.AddUserSecrets<Program>();
                        }
                    })
                    .Build();
                
                host.Run();
            }
        }
    ```

## Resources

- [Microsoft Docs - Register the user secrets configuration source](https://docs.microsoft.com/en-us/aspnet/core/security/app-secrets?view=aspnetcore-5.0&tabs=windows#register-the-user-secrets-configuration-source)
