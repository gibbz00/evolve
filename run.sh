#!/bin/bash
source ./env.sh

# give it internet access, done with --net=expose?

# --privilged flag to allow root access to devices?

# using bind mounts for faster persistent storage?
#   https://docs.docker.com/storage/bind-mounts/
docker run --rm -it $IMAGE_NAME /bin/sh
