## How to use MediatR

### How to use
1. Install the [MediatR](https://www.nuget.org/packages/MediatR/) nuget package

2. Register `MediatR` in `IServiceCollection`
  ```C#
    services.AddMediatR(Assembly.GetExecutingAssembly());
  ```

3. Create a Request
```C#
  public class GetEventsQuery: IRequest<List<EventListViewModel>>
  {
  }
```

4. Create a Request Handler
```C#
  public class GetEventsQueryHandler : IRequestHandler<GetEventsQuery, List<EventListViewModel>>
  {
    public async Task<List<EventListViewModel>> Handle (
      GetEventsQuery request, 
      CancellationToken cancellationToken)
    { 

    }
  }
```

### Links
- [GitHub - MediatR](https://github.com/jbogard/MediatR)
- [NuGet - MediatR](https://www.nuget.org/packages/MediatR/)