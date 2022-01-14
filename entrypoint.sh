#!/bin/sh

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"

# Allow the initialisation of the container during first launch
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

    # Install SQL Client
    apt-get update
    apt-get install -y mariadb-server
    service mariadb start

    # Change IIQ config file
    sed -i 's/localhost/iiq-mysql/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

    # Connect to mysql server and initiate DB
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
    echo Creating IIQ database ...
    mysql --user=root --password=root -h iiq-mysql < create_identityiq_tables-$IIQ_VERSION.mysql

    # Patch the database if the IIQ_PATCH variable environment is set
    [ ! -z "$IIQ_PATCH" ] && echo Patch $IIQ_VERSION$IIQ_PATCH detected, patching IIQ database ... && mysql --user=root --password=root -h iiq-mysql < upgrade_identityiq_tables-$IIQ_VERSION$IIQ_PATCH.mysql

    # Launch iiq console and import init files
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
    chmod +x iiq
    echo "import init.xml" | ./iiq console
    echo "import init-lcm.xml" | ./iiq console

    # Launch iiq patch command if the IIQ_PATCH variable environment is set
    [ ! -z "$IIQ_PATCH" ] && ./iiq patch $IIQ_VERSION$IIQ_PATCH

    # Start tomcat
    catalina.sh run
else
    echo "-- Not first container startup --"
    # Start tomcat
    catalina.sh run
fi
