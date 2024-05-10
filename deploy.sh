#!/usr/bin/env bash

docker buildx create --use --name drupal_builder

docker buildx build \
    -t banderson/drupal:7-base \
    --platform=linux/arm64,linux/amd64 \
    --push .

docker buildx rm drupal_builder
