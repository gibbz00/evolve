#!/bin/bash
source ./env.sh

# give it internet access, done with --net=expose?

# --privilged flag to allow root access to devices?

# using bind mounts for faster persistent storage?
#   https://docs.docker.com/storage/bind-mounts/
# TEMP: --it flag and /bin/sh, used for interactively checking out built image
docker run --rm -it $IMAGE_NAME 
