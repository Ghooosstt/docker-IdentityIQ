#!/bin/sh

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"

# Allow the initialisation of the container during first launch.
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

    # Install SQL Client.
    apt-get clean && apt-get autoclean && apt-get update
    apt-get install -y mariadb-server
    service mariadb start

    # Install Vim.
    apt-get install -y vim

    # Update IIQ database config file.
    sed -i 's/localhost/iiq-mysql/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

    # Update init file with mailslurper smtp server.
    sed -i 's/mail.example.com/iiq-mailslurper/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/config/init.xml

    # Setup iiq binary.
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
    chmod +x iiq

    # Generate schema if the package is a custom war.
    if [ "$IIQ_CUSTOM_WAR" = "yes" ]; then echo Custom war detected, generate iiq schema && ./iiq schema; fi

    # Connect to mysql server and initiate DB.
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/database
    echo Creating IIQ database ...
    if [ "$IIQ_CUSTOM_WAR" = "yes" ]; then mysql --user=root --password=root -h iiq-mysql < create_identityiq_tables.mysql; else mysql --user=root --password=root -h iiq-mysql < create_identityiq_tables-$IIQ_VERSION.mysql; fi

    # Patch the database if the IIQ_PATCH variable environment is set.
    if [ ! -z "$IIQ_PATCH" ]; then echo Patch $IIQ_VERSION$IIQ_PATCH detected, patching IIQ database... && mysql --user=root --password=root -h iiq-mysql < upgrade_identityiq_tables-$IIQ_VERSION$IIQ_PATCH.mysql; fi

    # Import objects using iiq console.
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
    echo import init.xml
    echo "import init.xml" | ./iiq console
    echo import init-lcm.xml
    echo "import init-lcm.xml" | ./iiq console
    if [ "$IIQ_CUSTOM_WAR" = "yes" ]; then echo import sp.init-custom.xml && echo "import sp.init-custom.xml" | ./iiq console; fi

    # Launch iiq patch command if the IIQ_PATCH variable environment is set.
    if [ ! -z "$IIQ_PATCH" ]; then ./iiq patch $IIQ_VERSION$IIQ_PATCH; fi

    # Start tomcat.
    catalina.sh run
else
    echo "-- Not first container startup --"
    # Start tomcat.
    catalina.sh run
fi
