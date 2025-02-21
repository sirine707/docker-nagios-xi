#!/bin/bash

# Start necessary services
systemctl start httpd
systemctl start mariadb
systemctl start crond
systemctl start nagios
systemctl start npcd
systemctl start ndo2db || echo "Warning: ndo2db service failed to start"

# Ensure Nagios XI databases are repaired
/usr/local/nagiosxi/scripts/repair_databases.sh

# Keep the container running
tail -f /usr/local/nagios/var/nagios.log
