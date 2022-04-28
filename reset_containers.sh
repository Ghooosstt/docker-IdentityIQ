#!/bin/sh
echo "Starting reset..."

docker-compose down

echo "Remove volumes..."
docker volume rm docker-identityiq_iiq-db docker-identityiq_iiq-ldapadmin docker-identityiq_iiq-openldap docker-identityiq_iiq-openldapconfig docker-identityiq_iiq-tomcat

echo "Remove custom tomcat image..."
docker image rm docker-identityiq_tomcat

echo "Reset completed successfully!"
