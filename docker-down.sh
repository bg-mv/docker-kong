#!/bin/zsh

echo Removing kong-net
docker network rm kong-net

echo Removing kong
docker rm -f kong-database
docker rm -f kong

echo Removing konga
docker rm -f konga

echo Cleaned
