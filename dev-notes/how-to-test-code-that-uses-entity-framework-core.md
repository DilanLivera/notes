## How to test code that uses Entity Framework Core

### How to mock the `DBContext` using in memory database
```C#
using Microsoft.Data.Sqlite;

var options = new DbContextOptionsBuilder<CourseContext>()
    .UseInMemoryDatabase($"CourseDatabaseForTesting{Guid.NewGuid()}")
    .Options;

using (var context = new CourseContext(options))
{
}
```
*Note - The InMemory database provider isn’t a relation database (i.e. - No referential integrity checks, No DefaultValueSql(string), No TimeStampor IsRowVersion, etc)*

### How to mock the `DBContext` using SQLite
```C#
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;

var connectionStringBuilder = new SqliteConnectionStringBuilder 
{ 
    DataSource = ":memory:" //ensures database is created in memory
};

var connection = new SqliteConnection(connectionStringBuilder.ToString());

var options = new DbContextOptionsBuilder<CourseContext>()
    .UseSqlite(connection)
    .Options;

using (var context = new CourseContext(options))
{
    context.Database.OpenConnection(); //if we don't open the connection, we get a SqliteException - No such table: TableName
    context.Database.EnsureCreated();
}
```
*Note - The SQLite database provider provides referential integrity*

### How to set up Entity framework Core logging in unit testing
1. Create a logger by implementing the `ILogger` interface
    ```C#
    using Microsoft.Extensions.Logging;

    internal class EFCoreLogger : ILogger
    {
        private readonly Action<string> _efCoreLogAction;
        private readonly LogLevel _logLevel;

        public EFCoreLogger(Action<string> efCoreLogAction, LogLevel logLevel)
        {
            _efCoreLogAction = efCoreLogAction;
            _logLevel = logLevel;
        }


        public IDisposable BeginScope<TState>(TState state)
        {
            return null;
        }

        public bool IsEnabled(LogLevel logLevel)
        {
            return logLevel >= _logLevel;
        }

        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, 
            Exception exception, Func<TState, Exception, string> formatter)
        {
            _efCoreLogAction($"LogLevel: {logLevel}, {state}");
        }
    }
    ```

2. Create a loggr provider by implementing the `ILoggerProvider` interface
    ```C#
    using Microsoft.Extensions.Logging;

    internal class LogToActionLoggerProvider : ILoggerProvider
    {
        private readonly Action<string> _efCoreLogAction;
        private readonly LogLevel _logLevel;

        public LogToActionLoggerProvider(
            Action<string> efCoreLogAction,
            LogLevel logLevel = LogLevel.Information)
        {
            _efCoreLogAction = efCoreLogAction;
            _logLevel = logLevel;
        }

        public ILogger CreateLogger(string categoryName)
        {
            return new EFCoreLogger(_efCoreLogAction, _logLevel);
        }

        public void Dispose()
        {
            // nothing to dispose
        }
    }
    ```

3. Use `UseLoggerFactory` method on `DbContextOptionsBuilder` to add a logger factory with the LoggerProvider created before
    ```C#
    public class AuthorRepositoryTests
    {
        private readonly ITestOutputHelper _output;

        public AuthorRepositoryTests(ITestOutputHelper output)
        {
            _output = output;
        }

        [Fact]
        public void AddAuthor_AuthorWithoutCountryId_AuthorHasBEAsCountryId()
        {
            var connectionStringBuilder = new SqliteConnectionStringBuilder 
            { 
                DataSource = ":memory:" 
            };
            var connection = new SqliteConnection(connectionStringBuilder.ToString());
            var loggerFactory = new LoggerFactory( 
            new[] 
            { 
                new LogToActionLoggerProvider(log =>
                {
                    _output.WriteLine(log);                         
                }) 
            });

            var options = new DbContextOptionsBuilder<CourseContext>()
                .UseLoggerFactory(loggerFactory)
                .UseSqlite(connection)
                .Options;

            //code to test Author has BE as CountryId if Author is without CountryId 
        }
    }
    ```

### Other things to remember

- Give an unique name to in memory database in each test 

- Improve tests by using multiple DB context instance
    ```C#
    [Fact]
    public void AddAuthor_AuthorWithoutCountryId_AuthorHasBEAsCountryId()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<CourseContext>()
            .UseInMemoryDatabase($"CourseDatabaseForTesting{Guid.NewGuid()}")
            .Options;

        using (var context = new CourseContext(options))
        {
            context.Countries.Add(new Entities.Country()
            {
                Id = "BE",
                Description = "Belgium"
            });

            context.SaveChanges();
        }

        using (var context = new CourseContext(options))
        {
            var authorRepository = new AuthorRepository(context);
            var authorToAdd = new Author()
            {
                FirstName = "Kevin",
                LastName = "Dockx",
                Id = Guid.Parse("d84d3d7e-3fbc-4956-84a5-5c57c2d86d7b")
            };

            // Act
            authorRepository.AddAuthor(authorToAdd);
            authorRepository.SaveChanges();
        }

        using (var context = new CourseContext(options))
        {
            // Assert
            var authorRepository = new AuthorRepository(context);
            var addedAuthor = authorRepository.GetAuthor(
                Guid.Parse("d84d3d7e-3fbc-4956-84a5-5c57c2d86d7b"));
            Assert.Equal("BE", addedAuthor.CountryId);
        }
    }
    ```

- When using multiple DB context instances, we only need to open the connection and ensure database is created once. This is because connection is reused between the contexts. So it stays open until it goes out of scope, which is at the end of the test. We only need to ensure database is created once because database is reused.
    ```C#
    [Fact]
    public void AddAuthor_AuthorWithoutCountryId_AuthorHasBEAsCountryId()
    {
        // Arrange
        var connectionStringBuilder = new SqliteConnectionStringBuilder 
        { 
            DataSource = ":memory:" 
        };

        var connection = new SqliteConnection(connectionStringBuilder.ToString());

        var options = new DbContextOptionsBuilder<CourseContext>()
            .UseSqlite(connection)
            .Options;

        using (var context = new CourseContext(options))
        {
            context.Database.OpenConnection();
            context.Database.EnsureCreated();

            context.Countries.Add(new Entities.Country()
            {
                Id = "BE",
                Description = "Belgium"
            });

            context.SaveChanges();
        }

        using (var context = new CourseContext(options))
        {
            var authorRepository = new AuthorRepository(context);
            var authorToAdd = new Author()
            {
                FirstName = "Kevin",
                LastName = "Dockx",
                Id = Guid.Parse("d84d3d7e-3fbc-4956-84a5-5c57c2d86d7b")
            };

            // Act
            authorRepository.AddAuthor(authorToAdd);
            authorRepository.SaveChanges();
        }

        using (var context = new CourseContext(options))
        {
            // Assert
            var authorRepository = new AuthorRepository(context);
            var addedAuthor = authorRepository.GetAuthor(
                Guid.Parse("d84d3d7e-3fbc-4956-84a5-5c57c2d86d7b"));
            Assert.Equal("BE", addedAuthor.CountryId);
        }
    }
    ```

### Links
- [Pluralsight - Testing with EF Core by Kevin Dockx](https://app.pluralsight.com/library/courses/ef-core-testing/table-of-contents)
- [Microsoft Docs - Testing code that uses EF Core](https://docs.microsoft.com/en-us/ef/core/testing/)