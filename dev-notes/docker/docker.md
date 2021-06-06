# Docker

## Images

- Images are built using a docker file. A Dockerfile contains instructions for building an image. Some of them are
  - `FROM` : Specify the base image which we use to built on top of. [docker docs - `FROM`](https://docs.docker.com/engine/reference/builder/#from)

    ```docker
    FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim
    ```

  - `WORKDIR` : Specify the working directory. After executing this command, all the following commands will be executed in the current working directory. [docker docs - `WORKDIR`](https://docs.docker.com/engine/reference/builder/#workdir)

    ```docker
    WORKDIR /path/to/workdir
    ```

  - `COPY` : Copies new files or directories from `<src>` and adds them to the filesystem of the container at the path `<dest>`. [docker docs - `COPY`](https://docs.docker.com/engine/reference/builder/#copy)

    ```docker
    COPY hom* /mydir/
    ```

  - `ADD` :  Copies new files, directories or remote file URLs from `<src>` and adds them to the filesystem of the image at the path `<dest>`. [docker docs - `ADD`](https://docs.docker.com/engine/reference/builder/#add)

    ```docker
    ADD test.txt relativeDir/
    ```

  - `RUN` : Execute any commands in a new layer on top of the current image and commit the results. The resulting committed image will be used for the next step in the `Dockerfile`. `RUN` is a build time instruction. [docker docs - `RUN`](https://docs.docker.com/engine/reference/builder/#run)

    ```docker
    RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'
    ```  

  - `ENV` : Sets the environment variable `<key>` to the value `<value>`. [docker docs - `ENV`](https://docs.docker.com/engine/reference/builder/#env)

    ```docker
    ENV MY_NAME="John Doe"
    ```

  - `EXPOSE` : Informs Docker that the container listens on the specified network ports at runtime. [docker docs - `EXPOSE`](https://docs.docker.com/engine/reference/builder/#expose)

    ```docker
    EXPOSE 80/tcp
    ```

  - `USER` : Sets the user name (or UID) and optionally the user group (or GID) to use when running the image and for any `RUN`, `CMD` and `ENTRYPOINT` instructions that follow it in the `Dockerfile`. [docker docs - `USER`](https://docs.docker.com/engine/reference/builder/#user)

    ```docker
    USER patrick
    ```

  - `CMD` : The main purpose of a `CMD` is to provide defaults for an executing container. These defaults can include an executable, or they can omit the executable, in which case you must specify an `ENTRYPOINT` instruction as well. [docker docs - `CMD`](https://docs.docker.com/engine/reference/builder/#cmd)

    ```docker
    CMD echo "This is a test." | wc -
    ```

  - `ENTRYPOINT` : Allows you to configure a container that will run as an executable. [docker docs - `ENTRYPOINT`](https://docs.docker.com/engine/reference/builder/#entrypoint)

    ```docker
    ENTRYPOINT ["top", "-b"]
    ```

- Build an image with `docker build -t [name-of-the-image] .` command
  
  ```powershell
  docker build -t react-app .
  ```

  `--tag` or `-t` : Name and optionally a tag in the ***name:tag*** format

- Start a new container with the given image name in interactive mode with `docker run -it [name-of-the-image]` command

  ```powershell
  docker run -it react-app
  ```

  We can pass a command to run when the container is starting.

  ```powershell
  docker run -it react-app bash
  ```

  ***Note: The difference between `run` and `start` command is, `run` command start a new container and `start` command start a stopped container.***
- Tag the image
  - During the build using `docker build -t  [image-name]:[tag-value] .`

    ```powershell
    docker build -t react-app:1.0.0 .
    ```

  - After the build using `docker images tag [image-name]:[current-tag-value] [image-name]:[new-tag-value]
  
    ```powershell
    docker image tag react-app:latest react-app:1.0.0
    ```

    ***Note: `latest` tag doesn't necessarily reference the latest image. We need to explicitly apply it to the latest image.***

- Save the image with `docker image save -o [tar-archive-name] [image-name]` command

  ```powershell
  docker image save -o react-app.tar react-app:1.0.0
  ```

- Load the image with `docker image load -i [tar-archive-name]` command

  ```powershell
  docker image load -i react-app.tar
  ```

## Containers

- Give a container a name using `docker run --name [container-name] [image-name]`

  ```powershell
  docker run --name blue_sky react-app:1.0.0
  ```

- Run a container in detached mode using `docker run -d [image-name]`

  ```powershell
  docker run -d react-app:1.0.0
  ```

- View the logs of a running container using `docker logs [container-id|container-name]`

  ```powershell
  docker logs react_app
  ```

  Use `-f, --follow` flag to follow the logs

  ```powershell
  docker logs -f react_app
  ```

- Publish a port using `docker run -p [outside-port]:[inside-port] [image-name]`

  ```powershell
  docker run -d -p 5000:80 --name weatherapi weatherapi:dev
  ```

- Execute a command in a running container using `docker exec [container-id|container-name] [command-to-be-executed]`

  ```powershell
  docker exec weather-api ls

  docker exec -it weather-api sh
  ```

- Stop a running container using `docker rm -f [container-id|container-name]`

  ```powershell
  docker rm -f weather-api
  ```

- Remove all the stopped containers using `docker container prune`

- All containers has its own file system. These are not visible to other containers. Volumes are the preferred mechanism for persisting data generated by and used by Docker containers([docker docs - storage - volumes](https://docs.docker.com/storage/volumes/)). It can be directory on the host or some where in the cloud.

  - Create a volume by using `docker volume create [volume-name]`

    ```powershell
    ❯ docker volume create app-data
    app-data
    ```

  - Inspect a volume using `docker volume inspect [volume-name]`

    ```powershell
    ❯ docker volume inspect app-data
    [
        {
            "CreatedAt": "2021-05-22T01:24:58Z",
            "Driver": "local",
            "Labels": {},
            "Mountpoint": "/var/lib/docker/volumes/app-data/_data",
            "Name": "app-data",
            "Options": {},
            "Scope": "local"
        }
    ]
    ```

  - Start a container with a volume using `docker run -v [volume-name]:[container-directory] [image-name]`. If the volume and/or the directory does not exist yet, docker will creates the volume and/or the directory. This could cause permission issues if you let docker creates the directory. To prevent this, create the directory in the docker file.

    ```powershell
    docker run -d -p 5000:80 --name weatherapi -v app-data:/app/data weatherapi:dev
    ```

  - Copy a file from container to the host using `docker cp [container-id]:[file-path-in-the-container] [destination-folder-in-the-host]`

    ```powershell
    docker cp 863a01dae3a9:app/data/log.txt .
    ```

  - Copy a file from host to the container using `docker cp [file-destination-in-the-host] [container-id]:[destination-folder-in-the-container]`

    ```powershell
    docker cp data.csv 863a01dae3a9:app/data
    ```

- Bind a directory on the host to a directory in the container `docker run -v [host-directory]:[destination-directory-in-the-container] [image-name]`. This will help during the development to refelect any changes done in the host, in the container.

  ```powershell
  docker run -d -p 5000:80 --name weatherapi -v $(pwd):/app weatherapi:dev
  ```

## Multi-container applications

- Set the version of the compose tool to use to validate the schema by using `version` keyword

  ```yaml
  version: "3.8"
  ```

- Computing components of an application are defined as `services`

  ```yaml
  version: "3.8"
  services:
    web:
      image: web

    mock-backend:
      image: backend
      profiles: ["dev"]
      depends_on:
        - db

    db:
      image: mysql
      profiles: ["dev"]
  ```

- Build or rebuild services in the compose file using `docker-compose build`. Services are built once and then tagged, by default as `folder_service`. Eg. `weatherapp_db`
  - Add `--no-cache` option to not use cache when building the image.
  - Add `--pull` option to pull a newer version of the image.

- Use `docker-compose up` command to build, (re)create, start, and attach to containers for a service.
  - Add `--build` option to build images before starting containers. When using this option we don't need to run the `docker-compose build` command before using the `docker-compose up`.
  - Add `-d` or `--detach` option to run containers in the background in detached mode.
  - Use `docker logs [container-id] -f` command to follow the logs of of an container when using detach mode.

- List all the containers relevent to the application by using `docker-compose ps`

- Stop containers and removes containers, networks, volumes, and images created by `up` command using `docker-compose down`
  - Add `--rmi type` option to remove the images. Type must be either `all`(Remove all images used by any service.) or `local`(Remove only images that don't have a custom tag set by the `image` field).

- To Run the db migrations, we need to update override the command in the docker file in the application(eg. backend or api application). This is done using the `command` keyword in the compose file.

  ```yaml
  version: "3.8"

  services:
    frontend:
      depends_on: 
        - backend
      build: ./frontend
      ports:
        - 3000:3000
      volumes: 
        - ./frontend:/app

    backend: 
      depends_on: 
        - db
      build: ./backend
      ports: 
        - 3001:3001
      environment: 
        DB_URL: mongodb://db/vidly
      volumes: 
        - ./backend:/app
      # 👇 command runs the db migrations and starts the application. 
      # Problem with this is db container might not be ready(depends_on option only wait until the container start) due to slow start.
      # To solve this we could use a script.
      # For more information goto https://docs.docker.com/compose/startup-order/
      # Use a waiting script with the command. eg. ./wait-for db:27017 && migrate-mongo up && npm start
      command: migrate-mongo up && npm start

    db:
      image: mongo:4.0-xenial
      ports:
        - 27017:27017
      volumes:
        - vidly:/data/db

  volumes:
    vidly:
  ```

  Or you could create a shell script with all the commands and run the script.

  ```shell
  # docker-entrypoint.sh
  # This should be in the application folder. eg. backend/docker-entrypoint.sh
  echo "Waiting for MongoDB to start..."
  ./wait-for db:27017 

  echo "Migrating the databse..."
  npm run db:up 

  echo "Starting the server..."
  npm start 
  ```

  ```yaml
    # removed for brevity
    backend: 
      depends_on: 
        - db
      build: ./backend
      ports: 
        - 3001:3001
      environment: 
        DB_URL: mongodb://db/vidly
      volumes: 
        - ./backend:/app
      command: ./docker-entrypoint.sh

    # removed for brevity
  ```

- To Run the tests, we can create another service in the compose file.

  ```yaml
  version: "3.8"

  services:
    frontend:
      depends_on: 
        - backend
      build: ./frontend
      volumes: 
        - ./frontend:/app
      ports:
        - 3000:3000

    frontend-tests:
      image: applicationName_frontend # eg. vidly_web
      volumes: 
        - ./frontend:/app
      command: npm test

    backend: 
      depends_on: 
        - db
      build: ./backend
      ports: 
        - 3001:3001
      environment: 
        DB_URL: mongodb://db/vidly

    db:
      image: mongo:4.0-xenial
      ports:
        - 27017:27017
      volumes:
        - vidly:/data/db

  volumes:
    vidly:
  ```

## Other Docker CLI Commands

- `docker version`
- `docker pull [image-name]`
- `docker imgages` or `docker image ls`
- `docker-compose up`
- `docker-compose down --rmi -all`
- `docker image prune` - Removes all dangling images.
- `docker container prune` - Removes all stopped containers.
- `docker container rm -f $(docker container ls -aq)` - Removes all(stopped and running) the containers.
- `docker image rm -f $(docker image ls -aq)` - Removes all(used and unused) the immages.
- `docker network ls` - Lists all the docker networks.

## Credits

- [Codewithmosh - The Ultimate Docker Course](https://codewithmosh.com/courses/the-ultimate-docker-course/)

## Reference

- [Docker Hub](https://hub.docker.com/)
- [Use the Docker command line](https://docs.docker.com/engine/reference/commandline/cli/)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Samples](https://docs.docker.com/samples/)
- [docker-compose CLI reference](https://docs.docker.com/compose/reference/)
- [Compose file version 3 reference](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes-for-services-swarms-and-stack-files)
- [The Compose file Specification](https://github.com/compose-spec/compose-spec/blob/master/spec.md#services-top-level-element)
