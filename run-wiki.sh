#!/bin/bash

docker run \
	-v /data/wiki:/data/wiki \
	-p 80:80 \
	-d \
	mediawiki

