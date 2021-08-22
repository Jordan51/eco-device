#!/bin/bash
# chmod u+x scripts/run_db_backup.sh

ENV_FILEPATH=$HOME/Dev/eco-device/.env

# Get .env file variables
# -----------------------
if [ -f $ENV_FILEPATH ]; then
  # Load Environment Variables
  export $(cat $ENV_FILEPATH | grep -v '#' | awk '/=/ {print $1}')
else
  # echo -e "\e[1;31mError: File .env not found \e[0m\n"
  echo "$(date '+%Y/%m/%d %H:%M:%S') error: File .env not found"
  exit 1
fi

DOCKER_DB_BACKUP_FULLPATH="$(echo $DOCKER_DB_BACKUP_DIRECTORY | tr -d '"')/$(date '+%Y-%m-%d_%H-%M')"

# Run db backup
# -------------
echo "$(date '+%Y/%m/%d %H:%M:%S') backing up db in docker container '$(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"')'"

docker exec \
  --user "$(id -u):$(id -g)" \
  $(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"') \
  influxd backup -database $(echo $INFLUXDB_DB | tr -d '"') \
  $(echo $DOCKER_DB_BACKUP_FULLPATH | tr -d '"') || echo "-" && exit 1

echo "-"

# Remove unnecessary (old) backups folders
# ----------------------------------------
# TODO: Find a way to limit backups to something like two folders only...

# Other stuff...
# --------------
# echo -e "\n\e[1mBacking up db (container $(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"')) in '\e[4m$(echo $DOCKER_DB_BACKUP_FULLPATH | tr -d '"')\e[0m\e[1m'... \e[0m\n"

# docker exec -it \
#   --user "$(id -u):$(id -g)" \
#   $(echo $DOCKER_DB_CONTAINER_NAME | tr -d '"') \
#   influxd backup -database $(echo $INFLUXDB_DB | tr -d '"') \
#   $(echo $DOCKER_DB_BACKUP_FULLPATH | tr -d '"') || exit 1

# echo -e "\n\e[1;32m -> Ok! \e[0m\n"
