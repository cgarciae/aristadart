#!/bin/bash
docker stop dartruntime
docker rm dartruntime

docker run -it -d -v "/c/Users/Cristian Garcia/Documents/Github/aristadart":/aristadart --link db:db -p 9090:8080 --name dartruntime google/dart bash
docker attach dartruntime

# Ahora copiar esto
# cd /aristadart && pub get && dart bin/server.dart