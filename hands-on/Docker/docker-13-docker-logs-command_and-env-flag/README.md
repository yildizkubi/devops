# Hands-on Docker-13 : docker logs command and env and env-file flag

Purpose of the this hands-on training is to teach students how to use docker logs, top, stats and cp commands.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- use docker logs, top, stats and diff commands.

## Outline

- Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Part 2 - Docker Logs command

- part 3 - env and env-file flag

## Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Launch a Docker machine on Amazon Linux 2 AMI with security group allowing SSH connections using the [Cloudformation Template for Docker Machine Installation](../S1A-docker-01-installing-on-ec2-linux2/docker-installation-template.yml).

- Connect to your instance with SSH.

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Docker Logs

- The docker logs command shows information logged by a running container.

- Run an nginx container.

```bash
docker container run --name ng -d nginx
```

- Fetch the logs of ng container with `docker logs` command.

```bash
docker logs ng
```

- Produce logs with curl command.

```bash
curl http://<ec2-ip>
```

- Display the detailed information about logs.

```bash
docker logs --details ng 
```

- Display the timestamps of logs.

```bash
docker logs -t ng 
```

- Display the logs until a time and since a time.

```bash
docker logs --until <timestamp> ng
docker logs --since <timestamp> ng
```

- Display the last 5 lines of logs.

```bash
docker logs --tail 5 ng
```

- Follow the container logs.

```bash
docker logs -f ng
```

## Part 3 - env and env-file flag

- Create a container and check the environment variable.

```bash
docker container run -it --name mycon --env var=key ubuntu
# printenv
```

- Create a `myfile.env` file as below.

```txt
a=1
b=2
c=3
```

- Create a container and check the environment variable.

```bash
docker container run -it --name mycon2 --env-file ./myfile.env ubuntu
# printenv
```

- Delete the containers.

```bash
docker container rm -f mycon mycon2
```