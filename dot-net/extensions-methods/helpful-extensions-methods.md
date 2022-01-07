# Helpful Extensions Methods

## Configuration Extensions

- `IsLoaded`
  - Implementation

    ```csharp
    /// <summary>
    /// Returns whether any configuration settings have been loaded
    /// </summary>
    /// <param name="config">Configuration object</param>
    /// <returns>True if any settings loaded</returns>
    public static bool IsLoaded(this IConfiguration configuration)
    {
        return configuration != null && configuration.AsEnumerable().Any();
    }
    ```

  - Tests

    ```csharp
    [Test]
    public void IsLoaded()
    {
        IConfiguration config = null;
        Assert.IsFalse(config.IsLoaded());
    }
    ```

- `AddStandardProviders`
  - Implementation

    ```csharp
    /// <summary>
    /// Adds the standard config providers - JSON file, environment variables, config override & secrets override
    /// </summary>
    /// <param name="configBuilder">Configuration builder</param>
    /// <returns>Configuration builder</returns>
    public static IConfigurationBuilder AddStandardProviders(
      this IConfigurationBuilder configurationBuilder)
    {
        return configurationBuilder
            .AddJsonFile("appsettings.json")
            .AddJsonFile("config/config.json", optional: true)
            .AddJsonFile("secrets/secrets.json", optional: true)
            .AddEnvironmentVariables();
    }
    ```

  - Tests

    ```csharp
    [Test]
    public void AddStandardProviders()
    {
        var builder = new ConfigurationBuilder();
        var config = builder.AddStandardProviders().Build();
        Assert.AreEqual(4, config.Providers.Count());
        Assert.IsTrue(config.IsLoaded());
    }
    ```

## Dictionary Extensions

- `ToQueryString`
  - Implementation

    ```csharp
    /// <summary>
    /// Creates a query string using Dictionary keys and values
    /// </summary>
    /// <param name="source">Dictionary object</param>
    /// <param name="keyValueSeparator">Separator to use to seperate the disctionary key and value</param>
    /// <param name="sequenceSeparator">Separator to use to seperate sequence</param>
    /// <returns>query string</returns>
    public static string ToQueryString(
        this Dictionary<string, string> source,
        string keyValueSeparator,
        string sequenceSeparator)
    {
        if (source is null)
        {
            return null;
        }

        if (source.Any() is false)
        {
            return string.Empty;
        }

        IEnumerable<string> pairs = source.Select(keyValuePair => string.Format(
            "{0}{1}{2}",
            keyValuePair.Key,
            keyValueSeparator,
            keyValuePair.Value));

        return string.Join(sequenceSeparator, pairs);
    }
    ```

  - Tests

    ```csharp
    using Shouldly;
    using Xunit;

    public class DictionaryExtensions_ToStringTests
    {
        [Fact]
        public void DictionaryIsNull_ReturnsNull()
        {
            Dictionary<string, string> dictionary = null;

            dictionary.ToQueryString("=", "&").ShouldBeNull();
        }

        [Fact]
        public void DictionaryIsEmpty_ReturnsEmptyString()
        {
            var dictionary = new Dictionary<string, string>();

            dictionary
                .ToQueryString("=", "&")
                .ShouldBeEquivalentTo(string.Empty);
        }

        [Fact]
        public void DictionaryHasValues_ReturnsFormatedString()
        {
            var dictionary = new Dictionary<string, string>
            {
                { "key1", "value1" },
                { "key2", "value2" },
                { "key3", "value3" }
            };

            dictionary
                .ToQueryString("=", "&")
                .ShouldBeEquivalentTo("key1=value1&key2=value2&key3=value3");
        }
    }
    ```
