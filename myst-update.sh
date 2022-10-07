#!/usr/bin/env bash
set -e
BASE_IMAGE="myst:latest"
REGISTRY="mysteriumnetwork"
IMAGE="$REGISTRY/$BASE_IMAGE"
HOSTMYSTDIR="myst-data" #this can be changed to your liking - make sure the path exists and matches your current settings.
OPTIONS="-p 4449:4449" #this can be changed to your needs. For example -p 4449:4449 .....
CID=$(docker ps | grep $IMAGE | awk '{print $1}')
docker pull $IMAGE

for im in $CID
do
    LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
    RUNNING=`docker inspect --format "{{.Image}}" $im`
    NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
    echo "Latest:" $LATEST
    echo "Running:" $RUNNING
    if [ "$RUNNING" != "$LATEST" ];then
        echo "upgrading $NAME"
        docker stop $NAME
        docker rm -f $NAME
        docker run -d --restart unless-stopped --cap-add NET_ADMIN $OPTIONS --name $NAME -v $HOSTMYSTDIR:/var/lib/mysterium-node mysteriumnetwork/myst:latest service --agreed-terms-and-conditions
    else
        echo "$NAME up to date"
    fi
done