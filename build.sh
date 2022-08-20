#!/bin/bash
source ./env.sh

docker build --tag $IMAGE_NAME ./src
