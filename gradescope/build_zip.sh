#!/usr/bin/env bash

set -ex
mkdir -p gradescope-zipballs

rm -rf gradescope
mkdir -p gradescope

for i in cse141pp-archlab CSE141pp-LabPython CSE141pp-DJR; do # CSE141pp-Tool-Moneta CSE141pp-SimpleCNN; do
    git clone ../$i gradescope/$i
done
cp ../env.sh gradescope
cp ../VERSION gradescope
cp -a ../shim gradescope

SECRETS=gradescope/${SECRETS_DIRECTORY#${CSE142L_ROOT}}
mkdir -p $SECRETS
cp $GOOGLE_APPLICATION_CREDENTIALS $SECRETS
cp $SECRETS_DIRECTORY/lab_encryption_key $SECRETS

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
	    > gradescope_env.sh
    
    rm -rf lab
    cse142 lab clone $LAB lab

    rm -rf ../gradescope-zipballs/gradescope-$DJR_CLUSTER-$LAB.zip
    zip -qr ../gradescope-zipballs/gradescope-$DJR_CLUSTER-$LAB.zip  *
#    exit 0
done 
