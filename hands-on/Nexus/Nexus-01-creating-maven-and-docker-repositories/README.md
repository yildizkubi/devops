# Hands-on 01: Creating Maven and Docker Repositories

The purpose of this hands-on training is to learn how to create and use Nexus repositories to store a Maven project and Docker images.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Create hosted and proxy repositories.

- Create a group repository consisting of hosted and proxy repositories.

- Consolidate all the components of a project into a repository group.

## Outline

- Part 1 - Start Nexus Repository and Create Credentials

- Part 2 - Create and Build a Maven Project (POM)

- Part 3 - Create Maven Proxy Repository

- Part 4 - Create New Components from Maven Central to the Proxy

- Part 5 - Configure and Build Components in Maven Hosted Repository

- Part 6 - Create a Maven Group Repository Consisting of Previously Created Hosted and Proxy Repositories

- Part 7 - Check the Components in the Group Repository by Accessing the UI

- Part 8 - Install Docker on Amazon Linux 2 EC2 Instance

- Part 9 - Create Docker Proxy Repository

- Part 10 - Create Docker Hosted Repository

## Part 1 : Start Nexus Repository and Create Credentials

- Launch a t3a.medium (Nexus needs 8 GB of RAM) EC2 instance using the Amazon Linux 2 AMI (ami-0bb4c991fa89d4b9b) with security group allowing `SSH (22), Nexus Port (8081), 8082 and 8083` connections.

- Connect to your instance with SSH:

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

- Update the OS:

```bash
sudo yum update -y
```

- Install Java:
Nexus and Maven is Java based application, so to run Nexus and Maven we have to install Java on the server.

```bash
sudo yum install java-1.8.0-openjdk -y
java -version
```

- Download and install Maven:

```bash
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
tar -zxvf $(ls | grep apache-maven-*-bin.tar.gz)
rm -rf $(ls | grep apache-maven-*-bin.tar.gz)
```

- Create an Environment Variable for Maven

```bash
echo "M2_HOME=/home/ec2-user/$(ls | grep apache-maven)" >> /home/ec2-user/.bashrc
echo 'export PATH=$PATH:$M2_HOME/bin' >> /home/ec2-user/.bashrc
bash
mvn -version
whereis mvn
```

- Download and install Nexus.

```bash
cd /opt
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
ls
```

```bash
sudo tar xvzf nexus.tar.gz
ls
sudo rm nexus.tar.gz
ls
```

Rename  nexus-3* directory for convenience:

```bash
sudo mv nexus-3* nexus
ls
```

- Give the ownership of the directories related to Nexus to the ec2-user:

```bash
ll
sudo chown -R ec2-user:ec2-user /opt/nexus
sudo chown -R ec2-user:ec2-user /opt/sonatype-work
ll
```

- Tell nexus that the ec2-user is going to be running the service. Edit the nexus.rc file with this `run_as_user="ec2-user"` content:

```bash
sudo vi /opt/nexus/bin/nexus.rc
```

```bash
cd /opt/nexus/bin
ls
```

- Add the path of nexus binary to the PATH variable and run nexus.

```bash
echo 'export PATH=$PATH:/opt/nexus/bin' >> /home/ec2-user/.bashrc
bash
nexus start
```

- Open your browser to load the repository manager: `http://<AWS public dns>:8081`

- To Retrieve the temporary password from `admin.password` file.

```bash
cat /opt/sonatype-work/nexus3/admin.password
```

- Open Nexus service from the browser and click `Sing in` upper right of the page. A box will pop up.
Write `admin` for Username and paste the string which you copied from admin.password file for the password.

- Click the Sign in button to start the Setup wizard. Click Next through the steps to update your password.

- Leave the Enable Anonymous Access box unchecked.

- Click Finish to complete the wizard.

## Part 2: Create and Build a Maven Project (POM)

- Use your terminal to create a sample POM.

- Create a project folder, name it `nexus-hands-on`, and change that directory.

```bash
cd
mkdir nexus-hands-on && cd nexus-hands-on
```

- Create a pom.xml in the nexus-hands-on directory: 

```bash
vi pom.xml
```

- Open the POM file with a text editor in your terminal and add the following snippet.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>nexus-proxy</artifactId>
  <version>1.0-SNAPSHOT</version>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.10</version>
    </dependency>
  </dependencies>
</project>
```

## Part 3: Create Maven Proxy Repository

- Open Nexus Repository Manager UI

- Create a repo called `maven-proxy-hands-on`.

- Click the setting button after that `Repositories`. Then click `Create repository` and choose recipe: `maven2 (proxy)`.

- Name: `maven-proxy-hands-on`

- Remote storage URL:  `https://repo1.maven.org/maven2`

- Click Create repository to complete the form.

- Nexus searches for settings.xml in the `/home/ec2-user/.m2` directory. .m2 directory is created after running the first mvn command.

```bash
mvn
# Get the public ip of instance
vi /home/ec2-user/.m2/settings.xml
```

- Your settings.xml file should look like this (Don't forget to change the URL of your repository and the password).

```xml
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS:8081/repository/maven-proxy-hands-on/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

## Part 4: Create New Components from Maven Central to the Proxy

- Run the build with the command `mvn package`. Your build is ready when you see a BUILD SUCCESS message.

```bash
pwd && ls
mvn package
ls
cd target && ls
```

- Click the Browse button in the main toolbar of Nexus to see the list of repositories.

- Click `Browse` from the left-side menu.

- Click `maven-proxy-hands-on`. You’ll see the components you built in the previous exercise.

- Click on the component name to review its details.

## Part 5: Configure and Build Components in Maven Hosted Repository

- Next up, configure Maven release and snapshot repositories (which come configured with the nexus repository manager) for deployment. This means that we will just update the pom.xml and settings.xml. We will not create repositories.

- Your mirror URL now should point to http://<AWS public DNS>:8081/repository/maven-public 

- Open your settings.xml and change the URL of your repository `maven-proxy-hands-on` to `maven-public`.

```bash
vi /home/ec2-user/.m2/settings.xml
```

```xml
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS>:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

- Add the distributionManagement element given below to your pom.xml file after the `</dependencies>` line. Include the endpoints to your maven-releases and maven-snapshots repos. Change localhost >>>> Public ip of your server.

```bash
# Get the public ip of instance
vi /home/ec2-user/nexus-hands-on/pom.xml
```

```xml
  <distributionManagement>
    <repository>
      <id>nexus</id>
      <name>maven-releases</name>
      <url>http://localhost:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
      <id>nexus</id>
      <name>maven-snapshots</name>
      <url>http://localhost:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
```

```bash
cd /home/ec2-user/nexus-hands-on
mvn clean deploy
cd target && ls
```

- Once you see BUILD SUCCESS, you can see the components in the repository from the UI. Check the components inside the snapshot and public repository. 

- Open the POM and remove the -SNAPSHOT tag from the version element.

```bash
vi /home/ec2-user/nexus-hands-on/pom.xml
```

Run the releases build: 

```bash
mvn clean deploy
```

- Once you see `BUILD SUCCESS`, you can see the components in the repository from the UI. Go and check the components in the release and public repository.

## Part 6: Create a Maven Group Repository Consisting of Previously Created Hosted and Proxy Repositories

- Create the repository group – the centralized endpoint to access hosted and proxied components. Remember to order the repositories as hosted, then proxy. Do the following to create the repository:

- Open Nexus Repository Manager UI

- Create a repo called `maven-all`.

- Click the setting button after that `Repositories`. Then click `Create repository` and choose recipe: `maven2 (group)`.

- Name: `maven-all`

- Drag and drop the Available repositories you created in the earlier exercises to the Members field.

- Click Create repository to complete the form.

- Copy the URL from the Group Repository you just created. (In this exercise, the repository URL is http://<AWS public DNS>:8081/repository/maven-all).

- Modify the mirror configuration in your settings.xml to point to your group. So the "<url>" tag should have `http://<AWS public DNS>:8081/repository/maven-all` inside it.

```bash
vi /home/ec2-user/.m2/settings.xml
```

- So your settings.xml should look like this: 

```xml
<settings>
  <mirrors>
    <mirror>
      <!--This sends everything else to /public -->
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://<AWS public DNS>:8081/repository/maven-all/</url>
    </mirror>
  </mirrors>
  <profiles>
    <profile>
      <id>nexus</id>
      <!--Enable snapshots for the built in central repo to direct -->
      <!--all requests to nexus via the mirror -->
      <repositories>
        <repository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </repository>
      </repositories>
     <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>http://central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>true</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
<activeProfiles>
    <!--make the profile active all the time -->
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
  <servers>
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>your-password</password> 
    </server>
  </servers>
</settings>
```

- Download components directly to your repository group.

```bash
cd /home/ec2-user/nexus-hands-on
mvn install
```

## Part 7: Check the Components in the local repository that was installed from the Group Repository that was configured

- Go inside the .m2/repository/ 

```bash
cd /home/ec2-user/.m2/repository && ls
```

- You will see that you have everything installed that is on your group repository. 

## Part 8: Install Docker on Amazon Linux 2 EC2 Instance

- Update the installed packages and package cache on your instance.

```bash
sudo yum update -y
```

- Install the most recent Docker Community Edition package.

```bash
sudo amazon-linux-extras install docker -y
```

- Start docker service.

- Init System: Init (short for initialization) is the first process started during the booting of the computer system. It is a daemon process that continues running until the system is shut down. It also controls services in the background. For starting the docker service, the init system should be informed.

```bash
sudo systemctl start docker
```

- Enable the docker service so that the docker service can restart automatically after reboots.

```bash
sudo systemctl enable docker
```

- Check if the docker service is up and running.

```bash
sudo systemctl status docker
```

- Add the `ec2-user` to the `docker` group to run docker commands without using `sudo`.

```bash
sudo usermod -a -G docker ec2-user
```

- Normally, the user needs to re-login into bash shell for the group `docker` to be effective, but `newgrp` command can be used activate `docker` group for `ec2-user`, not to re-login into bash shell.

```bash
newgrp docker
```

- Check the docker version without `sudo`.

```bash
docker version

Client:
 Version:           20.10.23
 API version:       1.41
 Go version:        go1.18.9
 Git commit:        7155243
 Built:             Tue Apr 11 22:56:36 2023
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server:
 Engine:
  Version:          20.10.23
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.18.9
  Git commit:       6051f14
  Built:            Tue Apr 11 22:57:17 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.19
  GitCommit:        1e1ea6e986c6c86565bc33d52e34b81b3e2bc71f
 runc:
  Version:          1.1.7
  GitCommit:        f19387a6bec4944c770f7668ab51c4348d9c2f38
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

- Check the docker info without `sudo`.

```bash
docker info
```

## Part 9 - Create Docker Proxy Repository

- Open Nexus Repository Manager UI

### For the blob storage

- Click the config (gear) icon.
- Navigate to `Blob Stores`.
- Create a new Blob Store of type `File`.
- Name it as `docker-hub`.
- Click `Save`.

### For the Security Realm

Click Security > Realms
Add the `Docker Bearer Token Realm`
Click `Save`

### For the repo

- Click `Repositories`
- Click `Create Repository` and select `docker (proxy)`
- Give it some name (docker-hub)
- Check `HTTP` and give it a valid port (8082)
- Check `Allow anonymous docker pull`
- Under Proxy > Remote Storage, enter this url: https://registry-1.docker.io
- Under Docker Index, select `Use Docker Hub`
- Under Storage > Blob Store, select the blob store you created earlier (docker-hub)
- Click `Create Repository`

### Docker Configuration

- We need to configure docker to define nexus repo as a docker image registry and accept working with HTTP instead of HTTPS because, by default, Docker Clients communicate with the repository using HTTPS.

- Add the new URL and port to the insecure-registries section of the docker config. Don't forget to change the public IP of the nexus server.

```bash
cd /etc/docker
sudo vi daemon.json
{
  "insecure-registries" : [
          "54.173.219.86:8082"
  ]
}
sudo systemctl restart docker
```

- Use the nexus repository as a docker container registry.

```bash
docker login -u admin -p admin 54.173.219.86:8082 # don't forget to change password.
docker pull 54.173.219.86:8082/alpine
docker image ls
```

- Click the Browse button in the main toolbar of Nexus to see the list of repositories.

- Click `Browse` from the left-side menu.

- Click `docker-hub`. You’ll see the docker images.

## Part 10 - Create Docker Hosted Repository

### For the blob storage

- Click the config (gear) icon.
- Navigate to `Blob Stores`.
- Create a new Blob Store of type File.
- Name it as `docker-private`.
- Click `Save`.

### For the repo

- Click `Repositories`
- Click `Create Repository` and select `docker (hosted)`
- Give it some name (docker-private)
- Check `HTTP` and give it a valid port (8083)
- Check `Enable Docker V1 API`
- Under Storage > Blob Store, select the blob store you created earlier (docker-private)
- Click `Create Repository`

### Docker Configuration

- Update the `/etc/docker/daemon.json` file as below.

```bash
cd /etc/docker
sudo vi daemon.json
{
  "insecure-registries" : [
          "54.173.219.86:8082",
          "54.173.219.86:8083"
  ]
}
sudo systemctl restart docker
```

- Use the nexus repository as a docker container registry.

```bash
docker login -u admin -p admin 54.173.219.86:8083
docker pull 54.173.219.86:8082/nginx
docker image ls
docker tag 54.173.219.86:8082/nginx 54.173.219.86:8083/myng
docker push 54.173.219.86:8083/myng
```

- Click the Browse button in the main toolbar of Nexus to see the list of repositories.

- Click `Browse` from the left-side menu.

- Click `docker-private`. You’ll see the docker images.

> Note: To use docker group repo, `Nexus Pro version` is required.