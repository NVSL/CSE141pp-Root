if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else
    export CSE142L_ROOT=$PWD
    export PUBSUB_TOPIC=CSE142L_testing1
    export PUBSUB_SUBSCRIPTION=DJR_jobs_subscription
    export GOOGLE_CLOUD_PROJECT=cse142l-dev
    
    export SECRETS_DIRECTORY=$CSE142L_ROOT/CSE141pp-Config/secrets/
    export GOOGLE_CREDENTIALS_FILE=cse142l-dev-c775b40fa9bf.json
    export GOOGLE_APPLICATION_CREDENTIALS=$SECRETS_DIRECTORY/$GOOGLE_CREDENTIALS_FILE
    export EMULATION_DIR=/tmp/emulation
    export CLOUD_MODE=EMULATION
    export DJR_DOCKER_SCRATCH=/tmp/djr_scratch
fi
