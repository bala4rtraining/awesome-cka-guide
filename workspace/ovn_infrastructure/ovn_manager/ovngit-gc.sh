#!/usr/bin/env bash

set -e

{
  sleep 60

  cd /data/git/pod1

  echo "--- `date -Iminute` --- GC start"

  git gc

  echo "--- `date -Iminute` --- GC end"
} &>> /var/log/ovngit-purge.log
