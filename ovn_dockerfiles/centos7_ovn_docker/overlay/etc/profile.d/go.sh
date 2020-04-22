#!/bin/bash

GOROOT="/usr/local/go/default"

if [ $# -ge 1 ]; then
  found=$(for x in /usr/local/go/$1*; do echo $x; done | sort | tail -1)
  if [ "$found" != "/usr/local/go/$1*" ]; then
    GOROOT=$found
  fi
fi

PATH=$GOROOT/bin:$(echo $PATH | sed -e 's#:/usr/local/go/[^/]*/bin##' -e 's#/usr/local/go/[^/]*/bin:##')

export GOROOT
export PATH
