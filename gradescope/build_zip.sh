#!/usr/bin/env bash

set -ex
mkdir -p gradescope-zipballs

rm -rf gradescope
mkdir -p gradescope

#cse141pp-archlab CSE141pp-LabPython CSE141pp-DJR CSE141pp-Tool-Moneta CSE141pp-SimpleCNN CSE141pp-Tool-Moneta-Pin
#for i in cse141pp-archlab CSE141pp-LabPython CSE141pp-DJR CSE141pp-Tool-Moneta CSE141pp-SimpleCNN; do
for i in CSE141pp-DJR CSE141pp-LabPython ; do
    git clone ../$i gradescope/$i
done
cp ../env.sh gradescope
cp ../VERSION gradescope

SECRETS=gradescope/${SECRETS_DIRECTORY#${CSE142L_ROOT}}
mkdir -p $SECRETS
cp $GOOGLE_APPLICATION_CREDENTIALS $SECRETS

cp setup.sh gradescope
cp run_autograder gradescope
pushd gradescope



for LAB in $LABS; do

    declare -px CLOUD_MODE \
	    DJR_SERVER \
	    DJR_CLUSTER \
	    DJR_JOB_TYPE \
	    CLOUD_NAMESPACE \
	    LAB \
	    >> gradescope_env.sh
    
    rm -rf lab
    cse142 lab clone $LAB lab

    rm -rf ../gradescope-zipballs/gradescope-$DJR_CLUSTER-$LAB.zip
    zip -qr ../gradescope-zipballs/gradescope-$DJR_CLUSTER-$LAB.zip  *
#    exit 0
done 
