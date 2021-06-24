if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else
    export CSE142L_ROOT=$PWD
    export PUBSUB_TOPIC=CSE142L_testing1
    export PUBSUB_SUBSCRIPTION=DJR_jobs_subscription
    export GOOGLE_CLOUD_PROJECT=ucsdgadgetron
    export GOOGLE_APPLICATION_CREDENTIALS=$CSE142L_ROOT/CSE141pp-Config/secrets/archlab-testing-credentials.json
    export EMULATION_DIR=/tmp/emulation
    export CLOUD_MODE=EMULATION
    export DJR_DOCKER_SCRATCH=/tmp/djr_scratch
fi
