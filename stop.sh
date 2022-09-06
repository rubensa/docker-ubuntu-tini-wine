#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-wine"

docker stop  \
  "${DOCKER_IMAGE_NAME}"
