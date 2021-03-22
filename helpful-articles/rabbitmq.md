# RabbitMQ

## How to install a plugin

- Go to `sbin` folder at `C:\Program Files\RabbitMQ Server\rabbitmq_server-3.8.9\sbin`
- Run command `rabbitmq-plugins enable plugin_name`. Eg. `rabbitmq-plugins enable rabbitmq_shovel`

## To test Shovel Plugin locally

- Install `rabbitmq_shovel` and `rabbitmq_shovel_management` plugins.
- Go to RabbitMQ dashboard
- Go to Admin tab. You should see **Shovel Status** and **Shovel Management** in left side navigation bar.
- Go to Shovel Management to create a shovel. Eg.
  - Source
    - Name - `FailedMessageShovel`
    - URI - `amqp://localhost:5672` and `entity.details.payload.handler.failed.message`
  - Destination
    - URI - `amqp://localhost:5672` and `failed.message.handling.subscriber`
- Click Add shovel
- Go to **Shovel Status** to check the status of the shovel. Eg. State == `running`
- If there were messages in the `entity.details.payload.handler.failed.message` queue, they should be moved to the `failed.message.handling.subscriber` queue now.

## Resources

- [RabbitMQ delay retry/schedule with Dead Letter Exchange](https://medium.com/@kiennguyen88/rabbitmq-delay-retry-schedule-with-dead-letter-exchange-31fb25a440fc)
- [Command Line Tools](https://rabbitmq.com/cli.html)
- [Shovel Plugin](https://www.rabbitmq.com/shovel.html)
- [Configuring Dynamic Shovels](https://www.rabbitmq.com/shovel-dynamic.html)