#!/bin/bash

export DJR_CLUSTER=djr-testing-cluster
export DJR_SERVER=http://0.0.0.0:5000
cse142 dev --detach --publish published=5000,target=5000 --name proxy-service  --image stevenjswanson/cse142l-service:latest bash -c "cse142 -v cluster server" 
cse142 dev --service --name runner-service  --image stevenjswanson/cse142l-service:latest bash -c "CLOUD_MODE=CLOUD cse142 --no-http -v cluster runner"

echo Set these:
echo export DJR_SERVER=http://$REAL_IP_ADDR:5000
echo export DJR_CLUSTER=djr-testing-cluster
echo 
