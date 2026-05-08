#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y --no-install-recommends \
    git \
    zip \
    unzip \
    xz-utils \
    curl \
    wget \
    openssl \
    ca-certificates \
    patch \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
