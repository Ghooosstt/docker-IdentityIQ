# Docker-IdentityIQ
Deploy a SailPoint IdentityIQ instance using Docker. This project use docker-compose to deploy:
* An Apache Tomcat container with IdentityIQ (JDK 11).
* A MySQL container.
* A phpMyAdmin container.
* An OpenLDAP container.
* A phpLDAPadmin container.
* A SMTP server container.

All theses services are connected through a network bridge.

*Tested from IdentityIQ 8.1 to IdentityIQ 8.5.*

## Requirements

To use this project, you must:
1. Install [Docker](https://www.docker.com/get-started).
2. Have an IdentityIQ zip archive with the version of your choice from [Compass](https://community.sailpoint.com/t5/IdentityIQ-Server-Software/ct-p/IdentityIQ).

## Setup

1. - Drop your **identityiq-\<version\>.zip** file, and your **identityiq\<version\>\<patch\>.jar** file in the root of this directory.

- You can also deploy a custom war file by dropping your **identityiq.war** file and following these conditions:
    1. File name must be 'identityiq.war'.
    1. The `iiq.properties` file in your custom war should be the default version included in the original IdentityIQ zip file (with the MySQL configuration).

2. Edit the **.env** file:
    1. Update the **IIQ_VERSION** variable by the version you are using *(Example: 8.2 for identityiq-8.2.zip)*.
    1. Specify a patch with **IIQ_PATCH** *(Example: p1 for identityiq-8.2p1.jar, nothing for no patch)*.
    1. Change the **IIQ_CUSTOM_WAR** variable to `yes` if you are deploying a custom war, `no` otherwise.

3. Go to the root of this directory and run `docker-compose up`. This command will build the **docker-identityiq_tomcat** image and create all the containers.

**At the first launch, the iiq-tomcat container will install mariadb client to communicate with the mysql container, and run the *create_identityiq_tables-\<version\>.sql* script. Then it will run the iiq console, import init files, import custom objects if IIQ_CUSTOM_WAR option is set, patch the database if a patch is provided, and start the tomcat server.**

![first-launch](https://user-images.githubusercontent.com/23320254/149496381-6e65d475-3312-4f7b-acbc-33131798ecf9.png)
  
After that, the iiq-tomcat container will launch the tomcat server after each start.

4. Once your environment is up, you can initialize the data (identities, accounts, roles) by launching the **Custom-TaskDefinition-Init-Environment** task.

![init-environment](https://github.com/EpiicDream/docker-IdentityIQ/assets/23320254/00baf226-79c3-4cfa-aca8-c31d2dcee161)

## Informations

The IdentityIQ server is available at [http://localhost:8080/identityiq/](http://localhost:8080/identityiq/).
* **Admin user:** spadmin
* **Admin password:** admin

The MySQL server listens on port **3306** and is accessible through the phpMyAdmin container at [http://localhost:8070](http://localhost:8070).
* **Admin user:** root
* **Admin password:** root

The OpenLDAP server listens on port **389** and is accessible through the phpLDAPadmin container at [https://localhost:6443](https://localhost:6443).
* **Admin user:** cn=admin,dc=my-company,dc=com
* **Admin password:** root
* LDAP domain: my-company.com

You can access to the Tomcat administration page at [http://localhost:8080/manager/html](http://localhost:8080/manager/html).
* **Admin user:** admin
* **Admin password:** admin

The MailSlurper server listens on port **25** and the emails are visible at [http://localhost:8090](http://localhost:8090).

## Communications between containers

Since all containers are connected through a network bridge, you must use container names to communicate with them. For example, to communicate from IdentityIQ to OpenLDAP or MailSlurper, use the following names:
* iiq-openldap
* iiq-mailslurper (email configuration is already setup by the *entrypoint.sh* script).

## Usage

To init the containers for the first time, use the command `docker-compose up`. 

To stop the containers, use the command `docker-compose stop`.

To start the containers, use the command `docker-compose start`.

To see logs from containers after start, use the command `docker-compose logs --follow`.

To list all the containers, use the command `docker ps -a`.

To execute bash inside a container, use the command `docker exec -it <container_name> bash`.

To remove the containers, use the command `docker-compose down`.

To recreate the containers, use the command `docker-compose up`.

## Update HR file

To update the HR file, you must connect to the **iiq-tomcat** container.

`docker exec -it iiq-tomcat bash`

Then edit the HR CSV file.

`vim /work/HR-file.csv`

Once edited, run the *Custom-TaskDefinition-Full* task in IdentityIQ to get the update and refresh the identities.

## Log your code

The container initialization add a custom logger in the log4j2.properties file.

To log, your logger must start by **custom.**

The logs are written to the file `/work/sailpoint.log` in the **iiq-tomcat** container.

````
// Example
// If your logger does not start with custom, you will not receive any log

import org.apache.log4j.Logger;

Logger log = Logger.getLogger("custom.rule.MoveLDAPAccount");
log.debug("Rule triggered");
````

## Reset the environment

If you want to deploy another IdentityIQ version, another patch version, or another custom war, you must:
1. Edit the **.env** file with the new version.
2. Execute the **reset_containers.bat** or **reset_containers.sh** scripts.
3. Rebuild the iiq-tomcat image without cache using `docker-compose build --no-cache`.
4. Recreate the containers using `docker-compose up`.

**WARNING, this action will delete your containers and all the data they contain.**

## Backup volumes data

If you need to send your containers data to another host, or if you want to backup your volumes data. You can use the `volumes_backup.bat` script for Windows or `volumes_backup.sh` script for Linux.

These scripts will generate a tar archive of MySQL and OpenLDAP containers data.

- **Your containers must be stopped.**

## Restore volumes data

Place the backup tar archives in the root of this directory, and use the `volumes_restore.bat` script for Windows or `volumes_backup.sh` script for Linux.

- **The iiq-tomcat container must be in the same version as the MySQL backup.** (*As the `volumes_backup` script performs a backup of the entire database, it is not possible to backup the data, upgrade the IIQ version, then restore the backup, because the IdentityIQ schema version will be the version retrieved during backup.*)

- **Your containers must exist and must be stopped.**

# Contribution

If you want to help improve the project, feel free to fork it and make a pull request. I will be happy to merge it.

# Ressources

* [tomcat](https://hub.docker.com/_/tomcat)
* [mysql](https://hub.docker.com/_/mysql)
* [phpmyadmin](https://hub.docker.com/_/phpmyadmin)
* [osixia/openldap](https://github.com/osixia/docker-openldap)
* [osixia/phpldapadmin](https://github.com/osixia/docker-phpLDAPadmin)
* [marcopas/docker-mailslurper](https://hub.docker.com/r/marcopas/docker-mailslurper)
