# Docker-IdentityIQ
Deploy a SailPoint IdentityIQ instance using Docker. This project use docker-compose to deploy:
* An Apache Tomcat container with IdentityIQ.
* A MySQL container.
* A phpMyAdmin container.
* An OpenLDAP container.
* A phpLDAPadmin container.
* A SMTP server container.

All theses services are connected through a network bridge.

## Requirements

To use this project, you must install [Docker](https://www.docker.com/get-started), and have an IdentityIQ zip archive with the version of your choice from [Compass](https://community.sailpoint.com/t5/IdentityIQ-Server-Software/ct-p/IdentityIQ).

## Setup

1. Before running any commands, you have to deposite your IdentityIQ zip archive in the root of the directory project. Then you have to edit the **.env** file and update the **IIQ_VERSION** variable by the version you are using *(Exemple: 8.2 for identityiq-8.2.zip)*. You can also specify a patch with **IIQ_PATCH** *(Exemple: p1 for identityiq-8.2p1.jar, nothing for no patch)*.

2. Then, verify that the file **entrypoint.sh** is in UNIX format (end line with LF). You can verify and change it if necessary with Notepad++.
* <img src="https://user-images.githubusercontent.com/23320254/150384352-9d832bef-43e5-487f-a01b-82dfca072036.png" width="550" height="300" />

3. Finally, go to the root of the directory and run `docker-compose up`. This command will build the **docker-identityiq_tomcat** image and create all the containers.

At the first launch, the iiq-tomcat container will install mariadb client to communicate with the mysql container, and run the *create_identityiq_tables-\<version\>.sql* script. Then it will run the iiq console, import init files, patch the database if a patch is provided, and start the tomcat server.

![first-launch](https://user-images.githubusercontent.com/23320254/149496381-6e65d475-3312-4f7b-acbc-33131798ecf9.png)
  
After that, the iiq-tomcat container will launch tomcat server after each start.

## Informations

The IdentityIQ server is available at [http://localhost:8080/identityiq/](http://localhost:8080/identityiq/).
* Admin user: spadmin
* Admin password: admin

The MySQL server listens on port 3306 and is accessible through the phpMyAdmin container at [http://localhost:8070](http://localhost:8070).
* Admin user: root
* Admin password: root

The OpenLDAP server listens on port 389 and is accessible through the phpLDAPadmin container at [https://localhost:6443](https://localhost:6443).
* LDAP domain: my-company.com
* Admin user: cn=admin,dc=my-company,dc=com
* Admin password: root

The MailSlurper server listens on port 25 and the emails are visible at [http://localhost:8090](http://localhost:8090).

## Usage

To stop the containers, use the command `docker-compose stop`.

To start the containers, use the command `docker-compose start`.

To see logs from containers after start, use the command `docker-compose logs --follow`.

To list all the containers, use the command `docker ps -a`.

To execute bash inside a container, use the command `docker exec -it <container_name> bash`.

To remove the containers, use the command `docker-compose down`.

To recreate the containers, use the command `docker-compose up`.

## Backup volumes data

If you need to send your containers data to another host, or if you want to backup your volumes data. You can use the `volumes_backup.bat` script for Windows or `volumes_backup.sh` script for Linux.

These scripts will generate a tarball for MySQL and for OpenLDAP containers data.

## Restore volumes data

To restore data, your containers must exist. Then place the backup tarballs in the root of this directory, and use the `volumes_restore.bat` script for Windows or `volumes_backup.sh` script for Linux.

## Update version

If you want to change the IdentityIQ version or change the patch version, you must:
1. Edit the **.env** file with the new version.
2. Remove the current containers using `docker-compose down`.
3. Remove the image **docker-identityiq_tomcat** using `docker image rm docker-identityiq_tomcat`.
4. Clean the old volumes using `docker volume prune`.
5. Rebuild the iiq-tomcat image and recreate the containers using `docker-compose up`.

**WARNING, this action will delete your containers and all the data they contain.**

# Ressources

* [tomcat](https://hub.docker.com/_/tomcat)
* [mysql](https://hub.docker.com/_/mysql)
* [phpmyadmin](https://hub.docker.com/_/phpmyadmin)
* [osixia/openldap](https://github.com/osixia/docker-openldap)
* [osixia/phpldapadmin](https://github.com/osixia/docker-phpLDAPadmin)
* [marcopas/docker-mailslurper](https://hub.docker.com/r/marcopas/docker-mailslurper)
