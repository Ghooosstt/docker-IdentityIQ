# Docker-IdentityIQ
Deploy an IdentityIQ instance using Docker.

This project use docker-compose to deploy a MySQL container and an Apache Tomcat with a network bridge.

## Requirements

To use this project, you must download and install [Docker](https://www.docker.com/get-started), and have an IdentityIQ zip archive of your choice from [Compass](https://community.sailpoint.com/t5/IdentityIQ-Server-Software/ct-p/IdentityIQ).

## Setup

Before running any commands, you have to deposite your IdentityIQ zip archive in the root of the directory project. Then you must edit the **docker-compose.yml** file and update the **IIQ_VERSION** arg by the version you are using *(Exemple: 8.2 for identityiq-8.2.zip)*. You can also specify a patch with the arg **IIQ_PATCH** *(Exemple: p1 for identityiq-8.2p1.jar, nothing for no patch)*.

Then, go to the root of the directory and run `docker-compose up`. This command will build the **docker-identityiq_tomcat** image and create the iiq-mysql and iiq-tomcat containers.

At the first launch, the iiq-tomcat container will install mariadb client to communicate with the mysql container, and run the *create_identityiq_tables-\<version\>.sql* script. Then it will run the iiq console, import init files, patch the database if a patch is provided, and start the tomcat server.

![first-launch](https://user-images.githubusercontent.com/23320254/149496381-6e65d475-3312-4f7b-acbc-33131798ecf9.png)
  
After that, the iiq-tomcat container will launch tomcat server after each start.

The IdentityIQ server is available at [http://localhost:8080/identityiq](http://localhost:8080/identityiq).

## Usage

To stop the containers, use the command `docker-compose stop`.

To start the containers, use the command `docker-compose start`.

To remove the containers, use the command `docker-compose down`.

To recreate the containers, use the command `docker-compose up`.

## Update version

If you want to change the IdentityIQ version or change the patch version, you must edit the **docker-compose.yml** file with the new version, remove the current containers using `docker-compose down`, remove the image **docker-identityiq_tomcat** using `docker image rm docker-identityiq_tomcat` then rebuild it and recreate the containers using `docker-compose up`.

**BE CAREFUL, this action will delete your containers and all the data they contain.**
