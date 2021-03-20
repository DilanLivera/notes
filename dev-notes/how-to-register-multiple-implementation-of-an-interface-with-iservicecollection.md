## How to register multiple implementation of an interface with `IServiceCollection`

### Create the interface
```C#
    public interface IEnricher
    {
        bool CanEnrich(SqsMessage message);

        void Enrich(SqsMessage message);
    }
```

### Create the implementations of the interface
```C#
    public class LocationEnricher : IEnricher
    {
        private readonly ILocationLookup _locationLookup;

        public LocationEnricher(ILocationLookup locationLookup)
        {
            _locationLookup = locationLookup;
        }

        public bool CanEnrich(SqsMessage message)
        {
            return !string.IsNullOrEmpty(message.IpAddress) &&
                message.Type == "FailedLogin";
        }

        public void Enrich(SqsMessage message)
        {
            message.City = _locationLookup.GetCity(message.IpAddress);
        }
    }

    public class DateEnricher : IEnricher
    {
        public bool CanEnrich(SqsMessage message)
        {
            return message.DateTimeLocal != default(DateTime);
        }

        public void Enrich(SqsMessage message)
        {
            message.DayOfWeek = message.DateTimeLocal.DayOfWeek.ToString();
        }
    }
```

### Register the services
```C#
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddSingleton<IEnricher, LocationEnricher>();
        services.AddSingleton<IEnricher, DateEnricher>();
    }
```

### Use the service/s
```C#
    public class MessageProcessor
    {
        private readonly IEnumerable<IEnricher> _enrichers;

        public MessageProcessor(IEnumerable<IEnricher> enrichers)
        {
            _enrichers = enrichers;
        }

        public void ProcessMessage(SqsMessage message)
        {
            var applicableEnrichers = _enrichers.Where(
                enricher => enricher.CanEnrich(message));

            foreach(var enricher in applicableEnrichers)
            {
                enricher.Enrich(message);
            }
        }
    }
```

### Links 
- [Steve Gordon - ASP.Net Core dependency injection - Registering multiple implementations of an interface](https://www.stevejgordon.co.uk/asp-net-core-dependency-injection-registering-multiple-implementations-interface)