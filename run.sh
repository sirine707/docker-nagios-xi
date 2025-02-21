#!/bin/bash

echo "Starting Nagios XI services..."

# Enable services to start on boot
systemctl enable mariadb httpd crond nagios npcd ndo2db

# Start services
systemctl start mariadb
systemctl start httpd
systemctl start crond
systemctl start nagios
systemctl start npcd
systemctl start ndo2db || echo "Warning: ndo2db service failed to start"

echo "Repairing Nagios XI databases..."
/usr/local/nagiosxi/scripts/repair_databases.sh

echo "Nagios XI is now running. Access it via http://localhost/ or http://your-server-ip/"

# Keep the container running
tail -f /usr/local/nagios/var/nagios.log
