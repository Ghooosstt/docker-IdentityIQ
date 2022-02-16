@echo off
echo Starting restore...

if exist "%cd%\backup-mysql.tar" (
  docker run --rm --volumes-from iiq-mysql -v "%cd%":/backup ubuntu bash -c "rm -rf /var/lib/mysql/* && tar xvf /backup/backup-mysql.tar"
) else (
  echo No MySQL backup found.
)

if exist "%cd%\backup-openldap.tar" (
  docker run --rm --volumes-from iiq-openldap -v "%cd%":/backup ubuntu bash -c "rm -rf /var/lib/ldap/* && tar xvf /backup/backup-openldap.tar"
) else (
  echo No OpenLDAP backup found.
)

if exist "%cd%\backup-openldapconfig.tar" (
  docker run --rm --volumes-from iiq-openldap -v "%cd%":/backup ubuntu bash -c "rm -rf /etc/ldap/slapd.d/* && tar xvf /backup/backup-openldapconfig.tar"
) else (
  echo No OpenLDAPConfig backup found.
)

echo Restore completed successfully!
