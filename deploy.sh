#!/usr/bin/env bash

set -e

cleanup() {
    docker buildx rm drupal_builder
}
docker buildx create --use --name drupal_builder
trap cleanup EXIT

VERSIONS=( "8.3.31" "8.4.21" )
for VERSION in "${VERSIONS[@]}"; do
    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        -t banderson/drupal:${VERSION} \
        -f mod_php/Dockerfile \
        --platform=linux/arm64,linux/amd64 \
        --push .

    docker buildx build \
        --build-arg PHPVERSION=${VERSION} \
        -t banderson/drupal:${VERSION}-fpm \
        -f php-fpm/Dockerfile \
        --platform=linux/arm64,linux/amd64 \
        --push .
done

docker buildx build \
    -t banderson/drupal-nginx:latest \
    --platform=linux/arm64,linux/amd64 \
    --push ./nginx

docker buildx build \
    -t banderson/drupal-nginx:saml \
    -f ./nginx/saml.Dockerfile \
    --platform=linux/arm64,linux/amd64 \
    --push ./nginx
