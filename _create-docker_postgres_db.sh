#!/usr/bin/env bash

# GOAL:
# * use as few dependencies as possible
# * create two tables: fred_cpi_1956_2023 and fred_cpi_descriptions
 
# RUN REQS:
# * docker
#   $ brew install --cask docker
#   $ docker pull postgres

# initialize a local Postgres DB
PWD=$(pwd)
VOL="/home/$(basename $PWD)"

# removed old DB (always start from scratch)
rm -Rf $PWD/db-data/*
mkdir -vp $PWD/db-data/pgdata

# look for open ports
BASE_PORT=5432
INCREMENT=1

port=$BASE_PORT
isfree=$(netstat -taln | grep $port)

while [[ -n "$isfree" ]]; do
    port=$[port+INCREMENT]
    isfree=$(netstat -taln | grep $port)
done

# run container
docker run --rm \
  -p 127.0.0.1:$port:5432 -v $PWD/db-data:/var/lib/postgresql/data -v $PWD:$VOL \
  -e POSTGRES_PASSWORD=pass123 -e PGDATA=/var/lib/postgresql/data/pgdata \
  -d postgres
echo "connect via localhost — 127.0.0.1:$port"

# grabs the latest container
CONTAINER=$(docker ps -lq)

# !!! CRITICAL
## just need a quick pause for the docker container to actually spin up!
sleep 2

# create a database and schema
## !!! MUST USE `-u postgres` to run commands as user "postgres"
## we connect to default database "postgres" (-d postgres)

## create "fred_cpi_1956_2023"
TABLE_NAME=fred_cpi_1956_2023
docker exec -u postgres -it $CONTAINER psql -U postgres -d postgres \
  -c "CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    date DATE,
    index TEXT,
    value DEC(5,1));"

### Upload the CSV file from local volume mount $VOL to the table
CSV_FILE=$VOL/data/$TABLE_NAME.csv
docker exec -u postgres -it $CONTAINER psql -U postgres -d postgres \
  -c "COPY $TABLE_NAME FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true);"

## create "fred_cpi_descriptions"
TABLE_NAME=fred_cpi_descriptions
docker exec -u postgres -it $CONTAINER psql -U postgres -d postgres \
  -c "CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    index TEXT,
    description TEXT);"

### Upload the CSV file to the table
CSV_FILE=$VOL/data/$TABLE_NAME.csv
docker exec -u postgres -it $CONTAINER psql -U postgres -d postgres \
  -c "COPY $TABLE_NAME FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true);"

## confirm tables
docker exec -u postgres -it $CONTAINER psql -U postgres -d postgres \
  -c "select table_catalog, table_schema, table_name from information_schema.tables where table_schema = 'public';"

## additonal commands, like setting PAGER to `less` with wrapped lines `-S`
docker exec -u postgres -it $CONTAINER psql -U postgres -c "\setenv PAGER 'less -S'"