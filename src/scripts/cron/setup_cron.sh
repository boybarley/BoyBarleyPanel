#!/bin/bash

# Add cron jobs for BoyBarleyPanel
PANEL_PATH="/var/www/boybarleypanel"

# Daily database backup
echo "0 0 * * * root php $PANEL_PATH/console backup:database" > /etc/cron.d/boybarleypanel-backup

# Daily log cleanup
echo "0 1 * * * root php $PANEL_PATH/console cleanup:logs" >> /etc/cron.d/boybarleypanel-backup

# Weekly system backup
echo "0 0 * * 0 root php $PANEL_PATH/console backup:system" >> /etc/cron.d/boybarleypanel-backup

# Monthly maintenance
echo "0 0 1 * * root php $PANEL_PATH/console maintenance:full" >> /etc/cron.d/boybarleypanel-backup

# Set proper permissions
chmod 644 /etc/cron.d/boybarleypanel-backup

# Restart cron service
systemctl restart cron
