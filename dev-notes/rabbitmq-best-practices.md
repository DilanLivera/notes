# RabbitMQ Best Practices

## Queues

- Keep your queue short (if possible)

  Many messages in a queue can put a heavy load on RAM usage. In order to free up RAM, RabbitMQ starts flushing (page out) messages to disk. The page out process usually takes time and blocks the queue from processing messages when there are many messages to page out, deteriorating queueing speed. Having many messages in the queue might negatively affect the performance of the broker.

  Additionally, it is time-consuming to restart a cluster with many messages since the index has to be rebuilt. It also takes time to sync messages between nodes in the cluster after a restart.

- Use **Quorum** Queues

  This is a replicated queue to provide high availability and data safety.
  
  Read more about why you should use Quorum queues in [The reasons you should switch to Quorum Queues](https://www.cloudamqp.com/blog/reasons-you-should-switch-to-quorum-queues.html) article.

- Enable lazy queues to get predictable performance

  Lazy queues are queues where the messages are automatically stored to disk, thereby minimizing the RAM usage, but extending the throughput time.

  Lazy queues create a more stable cluster with better predictive performance (According to [Part 1: RabbitMQ Best Practices - Enable lazy queues to get predictable performance](https://www.cloudamqp.com/blog/part1-rabbitmq-best-practice.html#enable-lazy-queues-to-get-predictable-performance) article). Messages will not get flushed to disk without a warning. You will not suddenly experience a hit to queue performance. If you are sending a lot of messages at once (e.g. processing batch jobs) or if you think that your consumers will not keep up with the speed of the publishers all the time, we recommend that you enable lazy queues.

  ***Note: You should disable lazy queues if you require really high performance, if the queues are always short, or if you have set a max-length policy.***

- Limit queue size with TTL or max-length

  For applications that often get hit by spikes of messages, and where throughput is more important than anything else, is to set a max-length on the queue. This keeps the queue short by discarding messages from the head of the queue so that it never gets larger than the max-length setting.

- Number of queues

  Queues are single-threaded in RabbitMQ, and one queue can handle up to about 50 thousand messages. You will achieve better throughput on a multi-core system if you have multiple queues and consumers and if you have as many queues as cores on the underlying node(s).

  The RabbitMQ management interface collects and calculates metrics for every queue in the cluster. This might slow down the server if you have thousands upon thousands of active queues and consumers. The CPU and RAM usage may also be affected negatively if you have too many queues.

  Disable busy polling in RabbitMQ if you have many entities (connections or queues), to decrease CPU usage.

- Split your queues over different cores

  Queue performance is limited to one CPU core. Therefore to get better performance, split your queues into different cores, and into different nodes, if you have a RabbitMQ cluster.

  RabbitMQ queues are bound to the node where they were first declared. Even if you create a cluster of RabbitMQ brokers, all messages routed to a specific queue will go to the node where that queue lives. You can manually split your queues evenly between nodes, but; the downside is remembering where your queue is located.

  Two plugins that will help you if you have multiple nodes or a single node cluster with multiple cores. More about plugins can be found at [RabbitMQ Plugins](https://www.rabbitmq.com/plugins.html#ways-to-enable-plugins).

  - Consistent hash exchange

    The consistent hash exchange plugin allows you to use an exchange to load-balance messages between queues. Messages sent to the exchange are consistently and equally distributed across many queues, based on the routing key of the message. The plugin creates a hash of the routing key and spreads the messages out between queues that have a binding to that exchange. It could quickly become problematically to do this manually, without adding too much information about numbers of queues and their bindings into the publisher.

    The consistent hash exchange plugin can be used if you need to get the maximum use of many cores in your cluster. Read more about the consistent hash exchange plugin at [RabbitMQ Consistent Hash Exchange Type](https://github.com/rabbitmq/rabbitmq-server/tree/master/deps/rabbitmq_consistent_hash_exchange)

    ***Note: It’s important to consume from all queues.***

  - RabbitMQ sharding

    The RabbitMQ sharding plugin does the partitioning of queues automatically (i.e. Once you define an exchange as sharded, then the supporting queues are automatically created on every cluster node and messages are sharded accordingly). The RabbitMQ sharding plugin gives you a centralized place where you can send your messages, plus load balancing across many nodes, by adding queues to the other nodes in the cluster. Note that it’s important to consume from all queues. Read more about RabbitMQ sharding at [RabbitMQ Sharding Plugin](https://github.com/rabbitmq/rabbitmq-server/tree/master/deps/rabbitmq_sharding).

- Don’t set your own names on temporary queues

  Giving a queue a name is important if you want to share the queue between producers and consumers, but it's not important if you are using temporary queues. Instead, let the server choose a random queue name instead of making up your own names, or modify the RabbitMQ policies.

- Auto-delete queues you are not using

  Client connections can fail and potentially leave unused resources (queues) behind, which could affect performance. There are three ways to delete a queue automatically.

  - Set a ***TTL policy*** in the queue; e.g. a TTL policy of 28 days deletes queues that haven't been consumed from for 28 days.

  - An ***auto-delete*** queue is deleted when its last consumer has canceled or when the channel/connection is closed (or when it has lost the TCP connection with the server).

  - An ***exclusive queue*** can only be used (consumed from, purged, deleted, etc.) by its declaring connection. Exclusive queues are deleted when their declaring connection is closed or gone (e.g., due to underlying TCP connection loss).

- Set limited use of priority queues

  Each priority level uses an internal queue on the Erlang VM, which takes up some resources. In most use cases it is sufficient to have no more than 5 priority levels.

## Payload (RabbitMQ message size and types)

- The amount of messages per second is a way larger bottleneck than the message size itself. While sending large messages is not a good practice, sending multiple small messages might be a bad alternative. A better idea is to bundle them into one larger message and let the consumer split it up. However, if you bundle multiple messages you need to keep in mind that this might affect the processing time. If one of the bundled messages fails, will all messages need to be re-processed? When setting up bundled messages, consider your bandwidth and architecture.

## Connections and channels

- Each connection uses about 100 KB of RAM (more, if TLS is used). Thousands of connections can be a heavy burden on a RabbitMQ server. In the worst case, the server can crash because it is out of memory. The AMQP protocol has a mechanism called channels that ***multiplexes*** a single TCP connection. It is recommended that each process only creates one TCP connection, using multiple channels in that connection for different threads. Connections should be long-lived. The handshake process for an AMQP connection is quite involved and requires at least 7 TCP packets (more, if TLS is used).

  Alternatively, channels can be opened and closed more frequently, if required, and channels should be long-lived if possible, e.g. reuse the same channel per thread of publishing. Don’t open a channel each time you are publishing. The best practice is to reuse connections and multiplex a connection between threads with channels. You should ideally only have one connection per process, and then use a channel per thread in your application.

- Don’t share channels between threads s most clients don’t make channels thread-safe (it would have a serious negative effect on the performance impact).

- Don’t open and close connections or channels repeatedly. This gives you a higher latency, as more TCP packages has to be sent and received.

- Separate connections for publisher and consumer to achieve high throughput. RabbitMQ can apply back pressure on the TCP connection when the publisher is sending too many messages for the server to handle. If you consume on the same TCP connection, the server might not receive the message acknowledgments from the client, thus effecting the consume performance. With a lower consume speed, the server will be overwhelmed.

- A large number of connections and channels might affect the RabbitMQ management interface performance. For each connection and channel performance, metrics have to be collected, analyzed and displayed.

## Acknowledgements and Confirms

- Acknowledgments let the server and clients know when to retransmit messages. The client can either ack the message when it receives it, or when the client has completely processed the message. Acknowledgment has a performance impact, so for the fastest possible throughput, manual acks should be disabled.

- A consuming application that receives important messages should not acknowledge messages until it has finished with them so that unprocessed messages (worker crashes, exceptions, etc.) don't go missing.

- Publish confirm is the same concept for publishing. The server acks when it has received a message from a publisher. Publish confirm also has a performance impact, however, keep in mind that it’s required if the publisher needs at-least-once processing of messages.

- All unacknowledged messages must reside in RAM on the servers. If you have too many unacknowledged messages, you will run out of memory. An efficient way to limit unacknowledged messages is to limit how many messages your clients prefetch (Prefetch value is used to specify how many messages are being sent to the consumer at the same time).

## Persistent messages and durable queues

## Definitions

- ***Ready*** - A message is ***Ready*** when it is waiting to be processed.

- ***Unacked*** - Consumer has promised to process them but has not acknowledged that they are processed. When the consumer crashed the queue knows which messages are to be delivered again when the consumer comes online. When you have multiple consumers the messages are distributed among them.

## Resources

- [Part 1: RabbitMQ Best Practices](https://www.cloudamqp.com/blog/part1-rabbitmq-best-practice.html)
