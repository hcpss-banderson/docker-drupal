#!/usr/bin/env bash

docker buildx create --use --name drupal_builder

VERSIONS=( "8.1" "8.2" "8.3" )

for VERSION in "${VERSIONS[@]}"; do
    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        --target base \
        -t banderson/drupal:${VERSION} \
        --platform=linux/arm64,linux/amd64 \
        --push .

    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        --target build \
        -t banderson/drupal:${VERSION}-build \
        --platform=linux/arm64,linux/amd64 \
        --push .
done

docker buildx rm drupal_builder
