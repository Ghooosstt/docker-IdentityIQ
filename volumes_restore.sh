#!/bin/sh
echo "Starting restore..."

if [ -f "./backup-mysql.tar" ]; then
	docker run --rm --volumes-from iiq-mysql -v $(pwd):/backup ubuntu bash -c "rm -rf /var/lib/mysql/* && tar xvf /backup/backup-mysql.tar"
else
	echo "No MySQL backup found."
fi

if [ -f "./backup-openldap.tar" ]; then
	docker run --rm --volumes-from iiq-openldap -v $(pwd):/backup ubuntu bash -c "rm -rf /var/lib/ldap/* && tar xvf /backup/backup-openldap.tar"
else
	echo "No OpenLDAP backup found."
fi

if [ -f "./backup-openldapconfig.tar" ]; then
	docker run --rm --volumes-from iiq-openldap -v $(pwd):/backup ubuntu bash -c "rm -rf /etc/ldap/slapd.d/* && tar xvf /backup/backup-openldapconfig.tar"
else
	echo "No OpenLDAPConfig backup found."
fi

echo "Restore completed successfully!"
