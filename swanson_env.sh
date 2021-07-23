if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else

    . ./env.sh
    
    export CLOUD_NAMESPACE=swanson-testing
    export PUBSUB_TOPIC=CSE142L_swanson_testing
    export PUBSUB_SUBSCRIPTION=DJR_swanson_testing_subscription
    export DJR_SERVER=http://$REAL_IP_ADDR:5000

    function check_dir() {
	if ! ( [ -e env.sh ] && [ -d CSE141pp-Config ] && [ -d CSE141pp-DJR ] ); then
	    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
	    return 1
	fi
    }
    function start_proxy_service () {
	check_dir || return 1
	stop_proxy_service
	DJR_SERVER=http://0.0.0.0:5000  cse142 dev --detach  --publish published=5000,target=5000  --name proxy-service  --image stevenjswanson/cse142l-dev:latest bash -c "cse142 -v server"
    }

    function debug_proxy_service () {
	check_dir || return 1
	stop_proxy_service
	export DJR_SERVER=http://0.0.0.0:5000
	cse142 dev --interactive --publish published=5000,target=5000  --env DEBUG_EXCEPTIONS=yes --name proxy-service  --image stevenjswanson/cse142l-dev:latest bash -c "cse142 -v server"
    }
    
    function start_runner_service () {
	check_dir || return 1
	stop_runner_service
	cse142 dev --detach  --name runner-service  --image stevenjswanson/cse142l-dev:latest bash -c "cse142 --no-http -v runner $@"
    }

    function debug_runner_service () {
	check_dir || return 1
	stop_runner_service
	cse142 dev --interactive --name runner-service   --env DEBUG_EXCEPTIONS=yes --image stevenjswanson/cse142l-dev:latest bash -c "cse142 --no-http -v runner $@"
    }
    

    function stop_runner_service() {
	docker container stop runner-service
	docker container rm runner-service
    }
    
    function stop_proxy_service() {
	docker container stop proxy-service
	docker container rm proxy-service
    }
    
fi

