# How to set up and use Rebus

## Configurer

- Delete a queue automatically

  ```csharp
  public class Startup
  {
        //Revomed for brevity

    public void ConfigureServices(IServiceCollection services)
    {
      services.AddRebus((rebusConfigurer, serviceProvider) =>
          {
            var rabbitConfig = serviceProvider.GetService<IOptions<RabbitMqMessageSubscriberConfiguration>>();

            rebusConfigurer.Transport(transport =>  transport
              .UseRabbitMq(
                rabbitConfig.Value.RabbitSettings.ConnectionString,
                rabbitConfig.Value.RabbitSettings.QueueName)
              .InputQueueOptions(queueOptionsBuilder => 
                queueOptionsBuilder.SetAutoDelete(autoDelete: true)));

            return rebusConfigurer;
          });
    }

        //Revomed for brevity
  }
  ```
