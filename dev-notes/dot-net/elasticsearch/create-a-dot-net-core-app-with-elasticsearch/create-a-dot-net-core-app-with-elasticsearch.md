# Create a .Net Core app with Elasticsearch

## Install Elasticsearch

1. Add the below code to a `docker-compose.yml` file

    ```powershell
    version: '3.8'
    services:

        es01:
          image: docker.elastic.co/elasticsearch/elasticsearch:7.9.1
          container_name: es01
          environment:
            - node.name=es01
            - cluster.name=es-docker-cluster
            - bootstrap.memory_lock=true
            - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
            - discovery.type=single-node
          ulimits:
            memlock:
              soft: -1
              hard: -1
          volumes:
            - data01:/usr/share/elasticsearch/data
          ports:
            - 9200:9200
          networks:
            - elastic

        kib01:
          image: docker.elastic.co/kibana/kibana:7.9.1
          container_name: kib01
          ports:
            - 5601:5601
          environment:
            ELASTICSEARCH_URL: http://es01:9200
            ELASTICSEARCH_HOSTS: http://es01:9200
          networks:
            - elastic

    volumes:
      data01:
        driver: local

    networks:
      elastic:
        driver: bridge
    ```

2. Goto the folder of where `docker-compose.yml` file is located.

3. Run `docker-compose up -d` or `docker compose up -d` command. Remove the `-d` flag to view the logs from the Elasticsearch and Kibana applications in realtime.

4. Goto `http://localhost:9200/` to test if the Elasticsearch running. You should get the below response back.

    ```json
    {
      "name" : "es01",
      "cluster_name" : "es-docker-cluster",
      "cluster_uuid" : "D8SKeXDOS-KAErbBtnxehg",
      "version" : {
        "number" : "7.9.1",
        "build_flavor" : "default",
        "build_type" : "docker",
        "build_hash" : "083627f112ba94dffc1232e8b42b73492789ef91",
        "build_date" : "2020-09-01T21:22:21.964974Z",
        "build_snapshot" : false,
        "lucene_version" : "8.6.2",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
      },
      "tagline" : "You Know, for Search"
    }
    ```

5. Goto `http://localhost:5601/` to visit the Kibana dashboard.
