#!/bin/bash
# chmod u+x scripts/init.sh

ENV_FILEPATH=$HOME/Dev/eco-device/.env

# Get .env file variables
# -----------------------
if [ -f $ENV_FILEPATH ]; then
  # Load Environment Variables
  export $(cat $ENV_FILEPATH | grep -v '#' | awk '/=/ {print $1}')
else
  echo -e "\e[1;31mError: File .env not found \e[0m\n"
  exit 1
fi

CRON_JOB_LOGS_DIRECTORY="$HOME/cronlogs"
HOST_DB_BACKUP_FULLPATH="$HOME/$(echo $HOST_DB_BACKUP_DIRECTORY | tr -d '"')"

# Create cron job logs directory
# ------------------------------
echo -e "\n\e[1mCreating cron job logs directory '\e[4m$CRON_JOB_LOGS_DIRECTORY\e[0m'\e[1m on host machine ... \e[0m\n"
mkdir -p $CRON_JOB_LOGS_DIRECTORY

if [ -d $CRON_JOB_LOGS_DIRECTORY ]; then
  echo -e "\e[1;32m -> Ok! \e[0m\n"
else
  echo -e "\e[1;31mError: could not create folder '\e[4m$HOST_DB_BACKUP_FULLPATH\e[0;31m'\e[0m\n"
fi

# Create db backup directory
# --------------------------
echo -e "\n\e[1mCreating db backup directory '\e[4m$(echo $HOST_DB_BACKUP_FULLPATH | tr -d '"')\e[0m'\e[1m on host machine ... \e[0m\n"
mkdir -p $HOST_DB_BACKUP_FULLPATH

if [ -d $HOST_DB_BACKUP_FULLPATH ]; then
  echo -e "\e[1;32m -> Ok! \e[0m\n"
else
  echo -e "\e[1;31mError: could not create folder '\e[4m$HOST_DB_BACKUP_FULLPATH\e[0;31m'\e[0m\n"
fi

# TODO: Create cron job (every month ?)
# ---------------------
# 0 0 1 * * ~/Dev/eco-device/scripts/run_db_backup.sh >> $CRON_JOB_LOGS_DIRECTORY/$(date -d"-0 days" +\%Y-\%m-\%d)_cronlog.log 2>&1

# Update db default retention policy
# ----------------------------------
echo -e "\e[1mChanging db default rentention policy to 5 years... \e[0m\n"
docker exec -it $(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"') influx -execute "ALTER RETENTION POLICY \"autogen\" ON $(echo $INFLUXDB_DB | tr -d '"') DURATION 1825d" || exit 1
docker exec -it $(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"') influx -execute "SHOW RETENTION POLICIES" -database $(echo $INFLUXDB_DB | tr -d '"') || exit 1
echo -e " \n\e[1;32m -> Ok! \e[0m\n"
