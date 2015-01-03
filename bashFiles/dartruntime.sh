#!/bin/bash
docker stop dartruntime
docker rm dartruntime

docker run -it -d -v /aristadart:/aristadart -p 9090:8080 --name dartruntime google/dart bash
docker attach dartruntime