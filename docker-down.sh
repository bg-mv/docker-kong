#!/bin/zsh

echo Removing konga
docker rm -f konga

echo Removing kong
docker rm -f kong
docker rm -f kong-database

echo Removing kong-net
docker network rm kong-net

echo Cleaned
