@echo off
echo Starting backup...

if exist "%cd%\backup-mysql.tar" (
  echo Old Mysql backup found, removing...
  del "%cd%\backup-mysql.tar"
)

if exist "%cd%\backup-openldap.tar" (
  echo Old OpenLDAP backup found, removing...
  del "%cd%\backup-openldap.tar"
)

if exist "%cd%\backup-openldapconfig.tar" (
  echo Old OpenLDAPConfig backup found, removing...
  del "%cd%\backup-openldapconfig.tar"
)

docker run --rm --volumes-from iiq-mysql -v "%cd%":/backup ubuntu tar cvf /backup/backup-mysql.tar /var/lib/mysql
docker run --rm --volumes-from iiq-openldap -v "%cd%":/backup ubuntu tar cvf /backup/backup-openldap.tar /var/lib/ldap
docker run --rm --volumes-from iiq-openldap -v "%cd%":/backup ubuntu tar cvf /backup/backup-openldapconfig.tar /etc/ldap/slapd.d

echo Backup completed successfully!
