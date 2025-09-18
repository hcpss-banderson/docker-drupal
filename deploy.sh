#!/usr/bin/env bash

docker buildx create --use --name drupal_builder

VERSIONS=( "8.3" "8.4" )
for VERSION in "${VERSIONS[@]}"; do
    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        -t banderson/drupal:${VERSION} \
        --platform=linux/arm64,linux/amd64 \
        --push .

    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        -t banderson/drupal:${VERSION}-frankenphp \
        -f frankenphp.Dockerfile \
        --platform=linux/arm64,linux/amd64 \
        --push .

    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        -t banderson/drupal:${VERSION}-fpm \
        -f fpm.Dockerfile \
        --platform=linux/arm64,linux/amd64 \
        --push .
done

docker buildx rm drupal_builder
