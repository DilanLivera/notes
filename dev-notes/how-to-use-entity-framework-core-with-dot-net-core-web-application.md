## How to use Entity Framework Core with .Net Core Web Application

### Packages
- [Microsoft.EntityFrameworkCore](https://www.nuget.org/packages/Microsoft.EntityFrameworkCore/)
- [Microsoft.EntityFrameworkCore.SqlServer](https://www.nuget.org/packages/Microsoft.EntityFrameworkCore.SqlServer/) - *Only if MS SQL Server is used*
- [Microsoft.EntityFrameworkCore.Design](https://www.nuget.org/packages/Microsoft.EntityFrameworkCore.Design/)
- [Microsoft.EntityFrameworkCore.Tools](https://www.nuget.org/packages/Microsoft.EntityFrameworkCore.Tools/)

### Code first
1. Create models
    ```C#
        public class Blog
        {
            public int BlogId { get; set; }
            public string Url { get; set; }

            public ICollection<Post> Posts { get; } = new List<Post>();
        }

        public class Post
        {
            public int PostId { get; set; }
            public JObject Content { get; set; }

            public int BlogId { get; set; }
            public Blog Blog { get; set; }
        }
    ```

2. Add configuration to the entity type [**Not Required**]
    ```C#
        //example for handling JObject properties
        public class PostConfiguration : IEntityTypeConfiguration<Post>
        {
            public void Configure(EntityTypeBuilder<Post> builder)
            {
                var jsonSerializerSettings = new JsonSerializerSettings 
                { 
                    NullValueHandling = NullValueHandling.Ignore 
                };

                builder
                    .Property(auditLog => auditLog.Request)
                    .HasConversion(
                        SerializeObject(jsonSerializerSettings), 
                        DeserializeObject(jsonSerializerSettings));

                builder
                    .Property(auditLog => auditLog.Response)
                    .HasConversion(
                        SerializeObject(jsonSerializerSettings),
                        DeserializeObject(jsonSerializerSettings));
            }

            private static Expression<Func<JObject, string>> SerializeObject(
                JsonSerializerSettings serializerSettings)
            {
                return jsonObject => JsonConvert.SerializeObject(jsonObject, serializerSettings);
            }

            private static Expression<Func<string, JObject>> DeserializeObject(
                JsonSerializerSettings serializerSettings)
            {
                return stringValue => JsonConvert.DeserializeObject<JObject>(
                    stringValue, 
                    serializerSettings);
            }
        }
    ```
    
2. Create a context
    ```C#
        public class BloggingContext : DbContext
        {
            public DbSet<Blog> Blogs { get; set; }
            public DbSet<Post> Posts { get; set; }
            
            public BloggingContext(DbContextOptions<AuditLogContext> options) : base(options)
            {
            }

            protected override void OnModelCreating(ModelBuilder modelBuilder)
            {
                modelBuilder.Entity<Blog>().ToTable("Blog");

                modelBuilder.Entity<Post>().ToTable("Posts");

                modelBuilder.ApplyConfiguration(new PostConfiguration());
            }
        }
    ```

3. Register the context in `IServiceCollection`
    ```C#
        services.AddDbContext<AuditLogContext>(options => options.UseSqlServer(
            Configuration.GetConnectionString(nameof(AuditLogContext))));
    ```

    *Note: if the migrations are in a different project*
    ```C#
        services.AddDbContext<AuditLogContext>(options => options.UseSqlServer(
            Configuration.GetConnectionString(nameof(AuditLogContext)),
            dbContextOptionsBuilder => dbContextOptionsBuilder.MigrationsAssembly("Blog.Web")));
    ```


4. Create a migration
    ```Powershell
        Add-Migration InitialCreate
    ```
    *Note - After running the command, check the generated code to see if it is correct*

4. Update the database
    ```Powershell
        Update-Database
    ```
    *Note: Use `-Verbose` flag to see the generated sql queries*

### Performance Tips
- Stop tracking when not writing data to the database using `AsNoTracking`. For more info goto [Microsoft Docs - Tracking vs. No-Tracking Queries](https://docs.microsoft.com/en-us/ef/core/querying/tracking)
    ```C#
        var blogs = context.Blogs
            .AsNoTracking()
            .ToList();
    ```

- Pick the best pattern to load related entities using the navigation properties in your model. For more info regarding tracking goto [Microsoft Docs - Loading Related Data](https://docs.microsoft.com/en-us/ef/core/querying/related-data/)

- Entity Framework Core allows you to drop down to raw SQL queries when working with a relational database with `FromSqlRaw` and `FromSqlInterpolated`. For more info goto [Microsoft Docs - Raw SQL Queries](https://docs.microsoft.com/en-us/ef/core/querying/raw-sql/)
    ```C#
        /*
         * FromSqlInterpolated
         */
        var searchTerm = "Lorem ipsum";

        var blogs = context.Blogs
            .FromSqlInterpolated($"SELECT * FROM dbo.SearchBlogs({searchTerm})")
            .Include(b => b.Posts)
            .ToList();

        /*
         * FromSqlRaw
         */
        var user = "johndoe";

        var blogs = context.Blogs
            .FromSqlRaw("EXECUTE dbo.GetMostPopularBlogsForUser {0}", user)
            .ToList();
    ```

- Because Entity framework core uses in-memory snapshots to track changes to our entities, if we happen to have an entity cachedin memory, we can save ourselves a trip to the database by looking it up with the `Find` and `FindAsync` methods. For more info goto [Microsoft Docs - DbContext.Find Method](https://docs.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.dbcontext.find) or [Microsoft Docs - DbContext.FindAsync Method](https://docs.microsoft.com/en-us/dotnet/api/microsoft.entityframeworkcore.dbcontext.findasync)

- `AddDbContextPool` enables pooling of `DbContext` instances. Context pooling can increase throughput in high-scale scenarios such as web servers by reusing context instances, rather than creating new instances for each request. For more info goto [Microsoft Docs - DbContext pooling](https://docs.microsoft.com/en-us/ef/core/performance/advanced-performance-topics#dbcontext-pooling)
    ```C#
        services.AddDbContextPool<BloggingContext>(
            options => options.UseSqlServer(connectionString));
    ```

### Links
- [Microsoft Docs - Tutorial: Get started with EF Core in an ASP.NET MVC web app](https://docs.microsoft.com/en-us/aspnet/core/data/ef-mvc/intro?view=aspnetcore-5.0)
- [YouTube - Getting Started with Entity Framework Core](https://www.youtube.com/watch?v=PpqdsJDvcxY&list=PLdo4fOcmZ0oX7uTkjYwvCJDG2qhcSzwZ6)