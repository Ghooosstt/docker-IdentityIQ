#!/bin/sh

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"

# Allow the initialisation of the container during first launch.
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

    # Install SQL Client.
    apt-get install -y mariadb-server
    service mariadb start

    # Install Vim.
    apt-get install -y vim

    # Update The IIQ database config file by replacing 'localhost' value by 'iiq-mysql'.
    sed -i 's/localhost/iiq-mysql/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/iiq.properties

    # Add custom logger in the log4j2.properties file
    echo '#Automatically added by the docker entrypoint.sh file' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'appender.file.type=File' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'appender.file.name=file' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'appender.file.fileName=/work/sailpoint.log' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'appender.file.layout.type=PatternLayout' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'appender.file.layout.pattern=%d{ISO8601} %5p %t %c{4}:%L - %m%n' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'rootLogger.appenderRef.file.ref=file' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo '' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'logger.custom.name=custom' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'logger.custom.level=debug' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties
    echo 'logger.sailpoint.appenderRef.syslog.ref=file' >>  /usr/local/tomcat/webapps/identityiq/WEB-INF/classes/log4j2.properties

    # Update init file with mailslurper smtp server. In a custom war, the default smtp config is in 'init-default_org.xml' file, and for default package smtp config is in 'init.xml' file.
    if [ "$IIQ_CUSTOM_WAR" = "yes" ]; then sed -i 's/mail.example.com/iiq-mailslurper/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/config/init-default_org.xml; else sed -i 's/mail.example.com/iiq-mailslurper/g' /usr/local/tomcat/webapps/identityiq/WEB-INF/config/init.xml; fi

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
    # We need to import init.xml file before executing the patch command.
    cd /usr/local/tomcat/webapps/identityiq/WEB-INF/bin
    echo import init.xml
    echo "import init.xml" | ./iiq console

    # In a custom war 'init.xml' file already contains 'init-lcm.xml' and 'sp.init-custom.xml' files. If it's not a custom war, we need to import 'init-lcm.xml'.
    if [ "$IIQ_CUSTOM_WAR" != "yes" ]; then echo import init-lcm.xml && echo "import init-lcm.xml" | ./iiq console; fi

    # Launch iiq patch command if the IIQ_PATCH variable environment is set.
    if [ ! -z "$IIQ_PATCH" ]; then ./iiq patch $IIQ_VERSION$IIQ_PATCH; fi

    # Import custom objects using the iiq console.
    echo import custom files from identityiq-objects folder
    echo "import /work/Custom-Rules.xml" | ./iiq console
    echo "import /work/Custom-Forms.xml" | ./iiq console
    echo "import /work/Custom-Applications.xml" | ./iiq console
    echo "import /work/Custom-Workflows.xml" | ./iiq console
    echo "import /work/Custom-Quicklinks.xml" | ./iiq console
    echo "import /work/Custom-TaskDefinitions.xml" | ./iiq console
    # We don't import ObjectConfigs if there is a custom war as this may erase some configurations from the custom war file.
    if [ "$IIQ_CUSTOM_WAR" != "yes" ]; then echo "import /work/Custom-ObjectConfigs.xml" | ./iiq console; fi

    # Start tomcat.
    catalina.sh run
else
    echo "-- Not first container startup --"
    # Start tomcat.
    catalina.sh run
fi
