#!/bin/bash

set -ex

if [ "$THIS_DOCKER_CONTAINER." = "." ]; then
    echo "You need to get into docker via cse142dev."
fi

for d in . $SUBDIRS; do
    (cd $d;
     echo Entering directory
     pwd
     if [ -e Makefile ] || [ -e makefile ]; then
	 if make -n setup; then # see if it has the target
	     make setup
	 fi
     fi
    )
done

pushd cfiddle
./install_prereqs.sh
pushd src/cfiddle/resources/libcfiddle/
make
popd
python -m pip install -e . --upgrade-strategy only-if-needed
popd
							     
