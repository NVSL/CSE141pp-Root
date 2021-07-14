#!/bin/bash

for d in $SUBDIRS; do
    (cd $d;
     if [ -e Makefile ] || [ -e makefile ]; then
	 make setup
     fi
    )
done

