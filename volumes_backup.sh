#!/bin/sh
echo "Starting backup..."

rm -f $(pwd)/backup-mysql.tar
rm -f $(pwd)/backup-openldap.tar
rm -f $(pwd)/backup-openldapconfig.tar

docker run --rm --volumes-from iiq-mysql -v $(pwd):/backup ubuntu tar cvf /backup/backup-mysql.tar /var/lib/mysql
docker run --rm --volumes-from iiq-openldap -v $(pwd):/backup ubuntu tar cvf /backup/backup-openldap.tar /var/lib/ldap
docker run --rm --volumes-from iiq-openldap -v $(pwd):/backup ubuntu tar cvf /backup/backup-openldapconfig.tar /etc/ldap/slapd.d

echo "Backup completed successfully!"
