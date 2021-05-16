# MediatR

## How to use

1. Install the [MediatR](https://www.nuget.org/packages/MediatR/) nuget package

2. Register `MediatR` in `IServiceCollection`

    ```csharp
    services.AddMediatR(Assembly.GetExecutingAssembly());
    ```

3. Create a Query or a Command

    ```csharp
    public class GetEventsQuery: IRequest<List<EventListViewModel>>
    {
    }
    ```

4. Create a Request Handler

    ```csharp
    public class GetEventsQueryHandler : IRequestHandler<GetEventsQuery, List<EventListViewModel>>
    {
        public async Task<List<EventListViewModel>> Handle (
          GetEventsQuery query, 
          CancellationToken cancellationToken)
        {
        }
    }
    ```

## Resources

- [GitHub - MediatR](https://github.com/jbogard/MediatR)
- [NuGet - MediatR](https://www.nuget.org/packages/MediatR/)
