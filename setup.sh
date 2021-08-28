#!/bin/bash

if [ "$THIS_DOCKER_CONTAINER." = "." ]; then
    echo "You need to get into docker via cse142dev."
fi

for d in . $SUBDIRS; do
    (cd $d;
     if [ -e Makefile ] || [ -e makefile ]; then
	 make setup
     fi
    )
done
