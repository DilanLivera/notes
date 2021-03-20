## C# Dictionary Extensions

### `ToQueryString`
- Implementation 
    ```C#
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
    ```C#
        using Shouldly;
        using Xunit;

        public class DictionaryExtensions_ToStringTests
        {
            [Fact(DisplayName = "Dictionary is null returns null")]
            public void DictionaryIsNull_ReturnsNull()
            {
                Dictionary<string, string> dictionary = null;

                dictionary.ToQueryString("=", "&").ShouldBeNull();
            }

            [Fact(DisplayName = "Dictionary is empty returns empty string")]
            public void DictionaryIsEmpty_ReturnsEmptyString()
            {
                var dictionary = new Dictionary<string, string>();

                dictionary
                    .ToQueryString("=", "&")
                    .ShouldBeEquivalentTo(string.Empty);
            }

            [Fact(DisplayName = "Dictionary has values returns formated string")]
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