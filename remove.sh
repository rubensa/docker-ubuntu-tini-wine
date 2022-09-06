#!/usr/bin/env bash

DOCKER_IMAGE_NAME="ubuntu-tini-wine"

docker rm \
  "${DOCKER_IMAGE_NAME}"
