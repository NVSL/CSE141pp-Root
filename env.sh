if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else
    export CSE142L_ROOT=$PWD
    export DOCKER_ORG=stevenjswanson
   
    export DOCKER_IMAGE_VERSION=s21-dev
    export DOCKER_CORE_IMAGE=$DOCKER_ORG/cse142l-core:$DOCKER_IMAGE_VERSION
    export DOCKER_DEVEL_IMAGE=$DOCKER_ORG/cse142l-dev:$DOCKER_IMAGE_VERSION
    export DOCKER_RUNNER_IMAGE=$DOCKER_ORG/cse142l-runner:$DOCKER_IMAGE_VERSION
    export DOCKER_SERVICE_IMAGE=$DOCKER_ORG/cse142l-service:$DOCKER_IMAGE_VERSION
    #DOCKER_USER_IMAGE=$DOCKER_ORG/cse142l-user:$DOCKER_IMAGE_VERSION

    export DJR_JOB_TYPE=CSE142L.CSE142LJob.CSE142LJob
    export CSE142L_RUNNER_DOCKER_IMAGE=stevenjswanson/cse142l-runner:latest
    export PUBSUB_TOPIC=CSE142L_testing1
    export PUBSUB_SUBSCRIPTION=DJR_jobs_subscription
    export EMULATION_DIR=/tmp/emulation
    export CLOUD_MODE=EMULATION
    export DJR_DOCKER_SCRATCH=/tmp/djr_scratch
    export GOOGLE_CLOUD_PROJECT=cse142l-dev
    
    export SECRETS_DIRECTORY=$CSE142L_ROOT/CSE141pp-Config/secrets/
    export PACKET_PROJECT_ID=1a5e2c60-b31f-49f9-85a1-84b4c5d8033f
    export DOCKER_USERNAME=stevenjswanson
    export DOCKER_ACCESS_TOKEN=$(cat $SECRETS_DIRECTORY/docker_hub_token)
    export GOOGLE_CREDENTIALS_FILE=cse142l-dev-c775b40fa9bf.json
    export GOOGLE_APPLICATION_CREDENTIALS=$SECRETS_DIRECTORY/$GOOGLE_CREDENTIALS_FILE

    PATH=$PATH:$CSE142L_ROOT/bin/
    
fi
