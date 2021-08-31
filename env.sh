
if ! ( [ -e env.sh ] && [ -e VERSION ] ); then
    echo "Doesn't look like you are in the root directory.  Source this from the config directory."
    CONFIG_FAILED=yes
else

    function source-env () {
	if ! [ -d $1 ]; then
	    echo "$1 doesn't exist"
	    return 1
	fi
	if [ -e $1/env.sh ]; then
	    #[ "$BE_QUIET." = "." ] && echo "sourcing $1/env.sh"
	    pushd $1 > /dev/null
	    . ./env.sh
	    popd > /dev/null
	fi
	return 0
    }
    function up-to-date() {
	if [ "$1." = "." ]; then
	    D=$PWD
	else
	    D=$1
	fi

	RED="\e[101m"
	NC="\e[0m"

	pushd $D > /dev/null
	if ! git diff --exit-code --stat 2>&1 >/dev/null ; then echo -e "${RED}You have uncommitted changes in $D $NC"; return 1;fi
	git remote update > /dev/null
	if ! git status -uno| grep -q 'Your branch is up.to.date with'; then echo -e "${RED}$D is not up-to-date with upstream $NC";return 1; fi
	popd
    }
    

    export HTTP_ROOT_REPO=https://github.com/NVSL/CSE141pp-Root.git
    export ROOT_REPO_BRANCH=main
    export HTTP_ARCHLAB_REPO=https://github.com/NVSL/cse141pp-archlab.git
    export ARCHLAB_REPO_BRANCH=master
    
    export CLOUD_NAMESPACE=default
    export CSE142L_ROOT=$PWD
    export DOCKER_ORG=stevenjswanson
    export DJR_SERVER=http://cse142l-dev.wl.r.appspot.com

    export JUPYTER_CONFIG_DIR=$CSE142L_ROOT/jupyter_config
    VERSION=$(cat $CSE142L_ROOT/VERSION)

    [ ".$REAL_USER" = "." ] && REAL_USER=$USER

    export DOCKER_IMAGE_VERSION=v$VERSION

    
    if [ ".$DEPLOYMENT" = ".yes" ]; then
	export DOCKER_IMAGE_INFIX=
    else
	DOCKER_IMAGE_INFIX=${DOCKER_IMAGE_INFIX:--$REAL_USER}
	export DOCKER_IMAGE_INFIX
    fi
    #export DOCKER_IMAGE_VERSION=s21-dev
    
    export DOCKER_CORE_IMAGE=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-core:$DOCKER_IMAGE_VERSION
    export DOCKER_DEVEL_IMAGE=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-dev:$DOCKER_IMAGE_VERSION
    export DOCKER_DEVEL_IMAGE_LATEST=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-dev:latest
    export DOCKER_RUNNER_IMAGE=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-runner:$DOCKER_IMAGE_VERSION
    export DOCKER_BASE_IMAGE=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-base:$DOCKER_IMAGE_VERSION
    export DOCKER_SERVICE_IMAGE=$DOCKER_ORG/cse142l$DOCKER_IMAGE_INFIX-service:$DOCKER_IMAGE_VERSION
    #DOCKER_USER_IMAGE=$DOCKER_ORG/cse142l-user:$DOCKER_IMAGE_VERSION

    export DJR_JOB_TYPE=CSE142L.CSE142LJob.CSE142LJob
    export CSE142L_RUNNER_DOCKER_IMAGE=stevenjswanson/cse142l-runner:latest
    export DJR_CLUSTER=djr-default-cluster
    export EMULATION_DIR=/tmp/emulation
    export CLOUD_MODE=CLOUD
    export DJR_DOCKER_SCRATCH=/tmp/djr_scratch
    export GOOGLE_CLOUD_PROJECT=cse142l-dev
    
    export SECRETS_DIRECTORY=$CSE142L_ROOT/CSE141pp-Config/secrets
    export PACKET_PROJECT_ID=1a5e2c60-b31f-49f9-85a1-84b4c5d8033f
    export DOCKER_USERNAME=stevenjswanson
    if [ -d $SECRETS_DIRECTORY ]; then
	export DOCKER_ACCESS_TOKEN=$(cat $SECRETS_DIRECTORY/docker_hub_token)
    fi
    export GOOGLE_CREDENTIALS_FILE=cse142l-dev-c775b40fa9bf.json
    export GOOGLE_APPLICATION_CREDENTIALS=$SECRETS_DIRECTORY/$GOOGLE_CREDENTIALS_FILE
    if [ -d $SECRETS_DIRECTORY ]; then
	export GITHUB_OAUTH_TOKEN=$(cat $SECRETS_DIRECTORY/git_oauth_token)
    fi
    export ALLOWED_GOOGLE_DOMAINS="ucsd.edu,eng.ucsd.edu"

    export MONETA_ROOT=$CSE142L_ROOT/CSE141pp-Tool-Moneta
    export CANELA_ROOT=$CSE142L_ROOT/CSE141pp-SimpleCNN

    export PIN_ROOT=$CSE142L_ROOT/CSE141pp-Tool-Moneta-Pin/

    PATH=$CSE142L_ROOT/bin:$PATH
    
    #CLOUD_MODE
    #DJR_SERVER
    #DJR_CLUSTER=djr-default-cluster
    
    export SUBDIRS="cse141pp-archlab CSE141pp-LabPython CSE141pp-DJR CSE141pp-Tool-Moneta CSE141pp-SimpleCNN CSE141pp-Tool-Moneta-Pin"

    for d in $SUBDIRS; do 
	source-env $d
    done

    
    # this checks if we are in an interactive shell.
    # no idea how it works.


    function bump-version() {
	
	pushd $CSE142L_ROOT > /dev/null
	branch=$(git rev-parse --abbrev-ref HEAD)
	if [ "$branch." != "main." ]; then
	    echo "Only bump main branch"
	    return 1
	fi
	t=$(cat VERSION)
	echo $[t + 1] > VERSION
	git add VERSION
	git commit -m "new-version"
	git push
	echo "New version is $(cat VERSION)"
	reconfig
	popd > /dev/null
    }

    function reconfig () {
	__HERE=$PWD
	cd $CSE142L_ROOT
	. env.sh
	cd $__HERE
    }

    function deployed() {
	export DEPLOYMENT=yes
	reconfig
    }

    if [[ $- == *i* ]]; then
	function notdeployed() {
	    undef DEPLOYED
	    reconfig
	}

	function ssh-login () {
	    
	    if ! [ -e $HOME/.ssh/ ]; then
		echo "$HOME/.ssh doesn't exist, so I'm not setting up an ssh-agent for you.  You'll need to type your password to clone each repo."
		return 1
	    fi
	    
	    if [ "$SSH_AUTH_SOCK." == "." ] || [ "$1." == "-f." ]; then
		eval `ssh-agent`
	    else
		echo Agent is already running socket = $SSH_AUTH_SOCK.  Not starting.
	    fi
	    if [ $(ssh-add -l | grep -v "The agent has no identities" | wc -l)  =  0 ]; then
		ssh-add
	    else
		echo It already has an identity loaded.  Not adding.
	    fi
	}

	function whereami () {
	    for i in DJR_CLUSTER THIS_DOCKER_IMAGE THIS_DOCKER_CONTAINER THIS_DOCKER_IMAGE_UUID WORK_OUTSIDE_OF_DOCKER REAL_IP_ADDR; do
		echo $i=$(eval  "echo \$$i")
	    done
	}
	
	function prompter() {
	    if git rev-parse --abbrev-ref HEAD 2> /dev/null > /dev/null; then
		GIT=[$(git rev-parse --abbrev-ref HEAD)]
	    else
		GIT=
	    fi

	    if [ ".$REAL_HOSTNAME" != "." ]; then
		R_HOST="($REAL_HOSTNAME)"
	    else
		R_HOST=
	    fi
		
	    PS1="\h$R_HOST:\w $DEPLOYED_TEXT$MISMATCH$GIT\$ "

	}

	

	PROMPT_COMMAND=prompter

	# if [ ".$THUNK_TO_HOME" = ".yes" ]; then # this is for students using the
	# 				      # runner image.  We source the
	# 				      # this file and then take them
	# 				      # home.
	#     echo Changing to $HOME
	#     cd $HOME
	#     unset THUNK_TO_HOME
	# else
	#     echo Not thunking
	# fi
	   
	whereami
	ssh-login

    fi
    
fi

