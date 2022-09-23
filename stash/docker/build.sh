#!/bin/bash
source ./env.sh

# using source to prevent .git and the rest to be copied into the build environement
docker build --tag $IMAGE_NAME ./src
