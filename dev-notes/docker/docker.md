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

- Start a container with the given image name in interactive mode with `docker run -it [name-of-the-image]` command

  ```powershell
  docker run -it react-app
  ```

  We can pass a command to run when the container is starting.

  ```powershell
  docker run -it react-app bash
  ```

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

## Other Docker CLI Commands

- `docker version`
- `docker pull [image-name]`
- `docker imgages` or `docker image ls`
- `docker-compose up`
- `docker-compose down --rmi -all`
- `docker image prune` - Removes all dangling images.
- `docker container prune` - Removes all stopped containers.

## Credits

- [Codewithmosh - The Ultimate Docker Course](https://codewithmosh.com/courses/the-ultimate-docker-course/)

## Reference

- [Docker Hub](https://hub.docker.com/)
- [Use the Docker command line](https://docs.docker.com/engine/reference/commandline/cli/)
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Samples](https://docs.docker.com/samples/)
