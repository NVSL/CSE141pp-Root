if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else

    . ./env.sh
    
    export CLOUD_NAMESPACE=swanson-testing
    export PUBSUB_TOPIC=CSE142L_swanson_testing
    export PUBSUB_SUBSCRIPTION=DJR_swanson_testing_subscription
    export DJR_SERVER=http://$REAL_IP_ADDR:5000

    function restart_proxy_service () {
	if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
	    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
	    return 1
	fi
	docker container stop proxy-service
	docker container rm proxy-service
	DJR_SERVER=http://0.0.0.0:5000  cse142 dev --detach  --publish published=5000,target=5000  --name proxy-service  --image stevenjswanson/cse142l-dev:latest bash -c "cse142 -v server"
    }
    function restart_runner_service () {
	if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
	    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
	    return 1
	fi
	docker container stop runner-service
	docker container rm runner-service
	cse142 dev --detach  --name runner-service  --image stevenjswanson/cse142l-dev:latest bash -c "cse142 --no-http -v runner --no-docker"
    }
	
fi

