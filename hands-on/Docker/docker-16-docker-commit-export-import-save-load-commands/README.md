# Hands-on Docker-16 : docker commit, export, import, save and load commands

Purpose of the this hands-on training is to teach students how to use docker logs, top, stats and cp commands.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- use docker logs, top, stats and diff commands.

## Outline

- Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Part 2 - Docker commit command

- Part 3 - Docker import and export commands

- Part 4 - Docker save and load commands

## Part 1 - Launch a Docker Machine Instance and Connect with SSH

- Launch a Docker machine on Amazon Linux 2 AMI with security group allowing SSH connections using the [Cloudformation Template for Docker Machine Installation](../S1A-docker-01-installing-on-ec2-linux2/docker-installation-template.yml).

- Connect to your instance with SSH.

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Docker commit command

- It can be useful to create a new image from a container's changes.

- Create a container named `commit-con`.

```bash
docker run --name commit-con -it ubuntu
```

- Create `myfile` inside the container.

```bash
root@58adf2a93ce8:/# pwd
/
root@58adf2a93ce8:/# touch myfile
```

- Create and list the image.

```bash
docker commit commit-con commit-image
docker image ls
```

- Run new container from `commit-image` and check that there is `myfile` file.

```bash
docker run --name newcommit-con -it commit-image
root@faa4f965ebc8:/# ls
bin  boot  dev  etc  home  lib  lib32  lib64  libx32  media  mnt  myfile  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

- We can also apply Dockerfile instruction to the created image like below.

```bash
docker commit --change "ENV myvar=myvalue" commit-con commit-image:env
```

- We add an environment variable to the image. Let's see.

```bash
docker run -it  commit-image:env
root@6d4e2be642bc:/# printenv myvar
myvalue
```

- We can also add `CMD` instructions.

```bash
docker commit --change 'CMD ["bin/sh", "-c", "echo hi"]' commit-con commit-image:cmd
```

- Let's test it.

```bash
$ docker run commit-image:cmd
hi
```

- Delete the containers

```bash
docker container prune
```

## Part 3 - Docker import and export commands

### docker export

- Export a container's filesystem as a tar archive.

- Create a container named `ex-con`.

```bash
docker run -it --name export-con alpine
/ # touch export-command
/ # exit
```

- Export the container's filesystem as a tar archive.

```bash
docker export export-con > export-image.tgz

# or
 docker export --output="export-image.tgz" export-con
```

- Check the file.

```bash
ls
```

### docker export

- Import the contents from a tarball to create a filesystem image and list the image.

```bash
cat export-image.tgz | docker import - exportimage:new
docker image ls
```

- Create a container from `exportimage:new` and check that there is `export-command` file.

```bash
$ docker run --name newexportcon -it exportimage:new sh
/ # ls
bin             etc             home            media           opt             root            sbin            sys             usr
dev             export-command  lib             mnt             proc            run             srv             tmp             var
```

- Delete the containers

```bash
docker container prune
```

## Part 4 - Docker save and load commands

- These commands are useful to transfer images to the other instances.

### docker save

- Save one or more images to a tar archive.

- pull busybox image.

```bash
docker pull busybox
```

- Save the busybox image as tar file.

```bash
docker save busybox > busybox.tar
ls -sh busybox.tar
```

### Save an image to a tar.gz file using gzip

```bash
docker save busybox:latest | gzip > busybox.tar.gz
ls -sh busybox.tar.gz
```

- We can copy this archive files to any environment and create our images again. We will use same environment. So, firstly we will delete `busybox` image.

```bash
docker image rm busybox
```

### docker load

- Load an image or repository from a tar archive (even if compressed with gzip, bzip2, xz or zstd) from a file or STDIN. It restores both images and tags.

- Create the image.

```bash
$ docker load < busybox.tar.gz

Loaded image: busybox:latest
$ docker images busybox
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
busybox      latest    9211bbaa0dbd   13 days ago   4.26MBB
```