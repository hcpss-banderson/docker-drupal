#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive \
  && apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
