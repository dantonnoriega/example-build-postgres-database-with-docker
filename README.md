# Build a Postgres Database using Docker

This repo showcases how simple it is to build, host, and query a locally-deployed Postgres database from a Docker container.

It showcases two approaches:

- **docker-compose.yml**
  - Set up correctly, using docker compose the easiest approach but it abstracts away a lot of what is happening. It passes all the necessary files to the container to build a database. But if you're like me, you like to "look under the hood" — that's what the other approach is for.
- **_create-docker_postgres_db.sql**
  - The "look under the hood" approach. This shell script builds a postgres database step by step. It builds the database from the "outside", targeting the container using `docker exec -u postgres -it <CONTAINER_ID> psql <COMMANDS>` 

The structure of this repo is as follows:

```sh
❯ basename $(pwd)
example-build-postgres-database-with-docker
❯ tree -L 2
.
├── R
│   └── _transform-fred_epi_wide_to_long.r
├── README.md
├── _create-docker_postgres_db.sh
├── data
│   ├── fred_cpi_1956_2023.csv
│   ├── fred_cpi_descriptions.csv
│   └── fredgraph.csv
├── docker-compose.yml
└── sql
    └── init-db.sql

4 directories, 8 files
```

Aside from acquiring and structuring your data files and SQL scripts accordingly, the process to spin up and build a Postgres database relatively straight-forward.


## Prerequisites

1. Docker Desktop
   
   Docker Desktop should install everything you need, including the CLI and `docker-compose`.

    ```sh
    # docker desktop
    brew install --cask docker # docker desktop
    # or visit https://www.docker.com/products/docker-desktop/
    ```
    
2. Postgres Docker Image
    
    Make sure Docker is running before running `docker pull`.

    ```sh
    # start docker; pull postgres image
    docker pull postgres
    ```
3. Postgres CLI (`psql`)

    ```sh
    brew install libpq
    ```

## Usage

1. Start Docker Desktop
2. Build the Postgres database
   
    Using `docker-compose`
   
    ```sh
    # "-d" ; run detached
    docker-compose up -d
    ```
    
    Using the shell script

    ```sh
    ./_create-docker_postgres_db.sh
    ```

3. Connect via `psql` like its a server

    ```sh
    $ psql -h 127.0.0.1 -p 5432 -U postgres -W
    # enter password ("pass123" in this example)
    ```

4. Run `psql` within the container itself

    ```sh
    # handy function to connect to the latest container in current directory
    # could also just run `docker exec -it <CONTAINER_ID> bash`
    function docker-bash () {
        LATEST=$(docker ps -lq)
        CONTAINER=${1:-$LATEST}
        docker exec -it $CONTAINER bash
    }
    docker-bash
    ```

    Once in the container, connect to `psql` 

    ```sh
    psql -U postgres
    ```

5. Run some SQL queries in `psql`

    ```sql
    select * from fred_cpi_1956_2023 where index = 'CUSR0000SA311' limit 10;
    ```

    OUTPUT
    
    ```
        date    |     index     | value 
    ------------+---------------+-------
    1956-01-01 | CUSR0000SA311 |  49.4
    1956-02-01 | CUSR0000SA311 |  49.6
    1956-03-01 | CUSR0000SA311 |  49.6
    1956-04-01 | CUSR0000SA311 |  49.6
    1956-05-01 | CUSR0000SA311 |  49.6
    1956-06-01 | CUSR0000SA311 |  49.6
    1956-07-01 | CUSR0000SA311 |  49.8
    1956-08-01 | CUSR0000SA311 |  49.8
    1956-09-01 | CUSR0000SA311 |  49.9
    1956-10-01 | CUSR0000SA311 |  50.0
    ```

6. (optional) Stop the container

    Stop via `docker-compose`

    ```sh
    # "--volumes" ; remove the volumes
    docker-compose down --volumes
    ```

    Stop the latest (or any) container

    ```sh
    # docker stop <CONTAINER_ID> ; $(docker ps -lq) grabs latest (`-l`) container id
    docker stop $(docker ps -lq)
    ```