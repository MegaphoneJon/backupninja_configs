#!/bin/sh                                                                                                                                                                                                          
# borg backupninja backup script
REPOSITORY=/opt/borg
export BORG_PASSPHRASE=''

info "Starting borg backup"

# Run the backup.
OUTPUT=$( (
borg create --verbose --stats  --progress --compression lz4         \
$REPOSITORY::'{hostname}-{now:%Y-%m-%d}' \
/etc \
/var/spool/cron/crontabs \
/var/backups \
/var/www \
/root \
/home \
/usr/local/bin \
/usr/local/sbin \
/var/lib/dpkg/status \
/var/lib/dpkg/status-old \
--exclude /home/*/.steam/steam/steamapps/common/ \
--exclude /home/*/.cache \
--exclude /home/*/.mozilla/firefox/*/Cache
) 2>&1)
if [ $? -ne 0 ] 
  then
  warning $OUTPUT
fi
info $OUTPUT

# Remove old backups.
OUTPUT=$( (
borg prune -v $REPOSITORY --prefix '{hostname}-' --keep-daily=7 --keep-weekly=4 --keep-monthly=6
) 2>&1)
if [ $? -ne 0 ] 
  then
  warning $OUTPUT
fi
info $OUTPUT

# Check the integrity of the backup.
OUTPUT=$( (
borg check $REPOSITORY
) 2>&1)
if [ $? -ne 0 ] 
  then
  warning $OUTPUT
fi
info $OUTPUT
unset BORG_PASSPHRASE
