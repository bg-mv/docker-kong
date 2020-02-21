#!/bin/zsh

echo Creating kong-net
docker network create kong-net

echo Creating database
docker run -d --name kong-database \
    --network=kong-net \
    -p 5432:5432 \
    -e "POSTGRES_USER=kong" \
    -e "POSTGRES_DB=kong" \
    -e "POSTGRES_PASSWORD=password" \
    postgres:9.6

echo Waiting for database to be alive
sleep 5

echo Running migrations
docker run --rm \
    --network=kong-net \
    -e "KONG_PG_HOST=kong-database" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=password" \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    kong:latest kong migrations bootstrap

echo Starting Kong
docker run -d --name kong \
    --network=kong-net \
    -e "KONG_PG_HOST=kong-database" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_PG_PASSWORD=password" \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong:latest
    
# Konga is a gui for kong
echo Preparing database for konga
docker run --rm \
    --network kong-net \
    pantsel/konga:latest -c prepare -a 'postgres' -u postgres://kong:password@kong-database:5432

echo Starting konga
docker run -d \
    --network kong-net \
    -e "TOKEN_SECRET=somerandomstring" \
    -e "DB_ADAPTER=postgres" \
    -e "DB_HOST=kong-database" \
    -e "DB_PORT=5432" \
    -e "DB_USER=kong" \
    -e "DB_PASSWORD=password" \
    -e "DB_DATABASE=kong" \
    -e "NODE_ENV=production" \
    -p 1337:1337 \
    --name konga \
    pantsel/konga
