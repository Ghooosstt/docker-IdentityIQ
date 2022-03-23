#!/bin/sh
echo "Starting reset..."

docker-compose down
docker volume prune -f
docker image rm docker-identityiq_tomcat

echo "reset completed successfully!"
