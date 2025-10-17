## Nextcloud upgrade
Connect to host
`ssh marulk`
Connect to database
`sudo su - postgres -c psql`
Copy database
`CREATE DATABASE nextcloud30 WITH TEMPLATE nextcloud29;`
Grant access
`GRANT ALL PRIVILEGES ON DATABASE nextcloud30 to nextcloud;`
Update currentDatabase in modules/nixos/nextcloud/default.nix

