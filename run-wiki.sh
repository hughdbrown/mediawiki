#!/bin/bash


service_name=docker
if ((ps -ef | grep -v grep | grep $service_name | wc -l) > 0)
then
    echo $service_name is running
else
    service $service_name start
fi

docker run \
	-v /data/wiki:/data/wiki \
	-p 80:80 \
	-d \
	mediawiki

