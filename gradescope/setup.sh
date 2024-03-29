#!/usr/bin/env bash


# DO NOT CHANGE THIS FILE NAME
# setup.sh in the root dir is required by Gradescope
#
# This file is the setup for the Gradescope autograder
# This is run by a Dockerfile to set up the autograder image
#
#	The Gradescope autograder will:
#		publish jobs to the Google PubSub job queue
#			with submission meta data from /autograder/submission_metadata.json
#		return a json file that has student facing data
#
#

# cd /autograder/source


ln -sf /autograder/source /cse142L 

pushd /cse142L

. env.sh
. gradescope_env.sh

set -ex

apt-get update --fix-missing
pip3 install --upgrade pip

# copied from core.docker
add-apt-repository ppa:deadsnakes/ppa; apt-get update  # for python3.9
apt-get install -y python3.9 python3.9-venv python3.9-dev && apt-get clean -y

python3.9 -m venv venv
. venv/bin/activate

python3.9 -m pip install --upgrade pip 
python3.9 -m pip install --upgrade setuptools
python3.9 -m pip install pyyaml pytz requests psutil grequests python-dateutil pandas
python3 -m pip install pyyaml pytz requests psutil grequests python-dateutil pandas



for i in CSE141pp-DJR CSE141pp-LabPython cfiddle delegate-function; do
    pushd $i
    python3.9 -m pip install  -e . # -e is important. Otherwise the encryption tools don't work because they are not in a module dir?
    popd
done

