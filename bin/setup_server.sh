#!/bin/bash

#
#mkdir /tmp/djr_scratch
# I got this by running the contents of cse142dev by hand and then passing `-n` to `cse142 dev`.  Then, I updated the mount paths.  The advantage is that 'make bootstrap' doesn't have to work -- it actually depends on _a lot_ of stuff, which is not great.
#
# sudo docker run -it --env GOOGLE_CLOUD_PROJECT --env DJR_CLUSTER --env DJR_DOCKER_SCRATCH --env CLOUD_MODE --env DJR_SERVER --env DJR_JOB_TYPE --env CSE142L_RUNNER_DOCKER_IMAGE --env WORK_OUTSIDE_OF_DOCKER --env HOME_OUTSIDE_OF_DOCKER --env REAL_IP_ADDR --env REAL_HOSTNAME --env EMULATION_DIR --env CLOUD_NAMESPACE --env REAL_USER --env SECRETS_DIRECTORY --env PACKET_PROJECT_ID --env DOCKER_USERNAME --env DOCKER_ACCESS_TOKEN --env GOOGLE_CREDENTIALS_FILE --env GITHUB_OAUTH_TOKEN --env THIS_DOCKER_CONTAINER=swanson-dev --env HOME=/root --mount type=bind,source=/var/run/docker.sock,dst=/var/run/docker.sock --mount type=bind,source=/tmp,dst=/tmp --mount type=bind,source=$HOME,dst=/root --mount type=bind,source=$PWD,dst=/cse142L --mount type=bind,source=/tmp/djr_scratch,dst=/tmp/djr_scratch --env GOOGLE_APPLICATION_CREDENTIALS=/cse142L/CSE141pp-Config/secrets/cse142l-dev-c775b40fa9bf.json --workdir /cse142L --name swanson-dev --hostname swanson-dev-192.168.4.21 stevenjswanson/cse142l-swanson-dev:latest bash --rcfile env.sh
#
###############################################################################
#	This script sets up a packet server
###############################################################################

set -x #print out commands as we execute them.
set -v

#. $CONFIG_REPO_ROOT/funcs.sh

if [ "$APTGET." = "." ]; then
    APTGET=apt-get
fi

mkdir -p /bootstrap/cse142L
cd /bootstrap/cse142L

###############################################################################
#	Propagate configuration information
###############################################################################

#declare -px $KEY_ENVIRONMENT_VARIABLES > $RUNLAB_STATUS_DIRECTORY/deployment_config
#rm -rf $RUNLAB_STATUS_DIRECTORY/node_status

#(date; echo initial setup) >> $RUNLAB_STATUS_DIRECTORY/node_status

# TODO
# https://unix.stackexchange.com/questions/153693/cant-use-userspace-cpufreq-governor-and-set-cpu-frequency
# https://wiki.ubuntu.com/Kernel/KernelBootParameters
#
# maybe add  acpi_enforce_resources=lax to kernel cmdline


###############################################################################
#	To install basic dev tools
###############################################################################


$APTGET update --fix-missing
echo -ne 'Y\n1\n' $APTGET dist-upgrade -y
$APTGET -y install git emacs
$APTGET install -y python3.9 python3-pip python3.9-venv
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py; python3.9 /tmp/get-pip.py
update-alternatives --install /usr/bin/python python /usr/bin/python3.9 10
pip3 install --upgrade pip

###############################################################################
#	To install docker
###############################################################################
# https://docs.docker.com/engine/install/ubuntu/

if ! docker --version; then
    $APTGET install -y \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    gnupg \
	    lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
	"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    $APTGET update
    $APTGET install -y docker-ce docker-ce-cli containerd.io
fi

#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

#apt-key fingerprint 0EBFCD88


# add-apt-repository \
#         "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# $APTGET update
# $APTGET -y install  docker-ce docker-ce-cli containerd.io

# (date; echo docker install finished) >> $RUNLAB_STATUS_DIRECTORY/node_status
###############################################################################
#	pull Docker images
###############################################################################

# pushd $INSTALL_ROOT
# make pull
# popd 

###############################################################################
#       Mount point for iso images (for spec)
###############################################################################

mkdir -p /mnt/iso

###############################################################################
#	Install and enable runlab service
###############################################################################

#pushd $CONFIG_REPO_ROOT/cloud
#cp runlab.init.d /etc/init.d/runlab
#chmod +x /etc/init.d/runlab
#update-rc.d runlab defaults || chkconfig --add runlab # one for  ubuntu one for redhat/centos
#popd 

#(date; echo runlab service install finishd) >> $RUNLAB_STATUS_DIRECTORY/node_status
###############################################################################
#	build and install cache control module
###############################################################################

# this nonsense is for ubuntu 20.10, which doesn't provide a kernel header
# package for the default kernel it ships with.
# We fake it with a slightly higher patch level and then let it build with a soft link.
if [ "$(uname -r)" = "5.8.0-26-generic" ]; then 
    export EFFECTIVE_UNAME=5.8.0-63-generic
else
    export EFFECTIVE_UNAME=$(uname -r)
fi

$APTGET -y install kmod linux-headers-generic build-essential linux-headers-$EFFECTIVE_UNAME

if [ "$(uname -r)" = "5.8.0-26-generic" ]; then 
    ln -sf /lib/modules/5.8.0-63-generic/build /lib/modules/5.8.0-26-generic/build
fi

pushd $INSTALL_ROOT/cse141pp-archlab/cache_control/
make
make modules_install
depmod
modprobe cache_control
echo cache_control >> /etc/modules-load.d/modules.conf

# Load msr by default
echo msr >> /etc/modules-load.d/modules.conf
popd


###############################################################################
#	Cleanup
###############################################################################

$APTGET clean -y

###############################################################################
#	Enable userspace CPU freq control and reboot.
###############################################################################

grubby --update-kernel=ALL --args="intel_pstate=disable" || true #  This works on redhat

if tail -1 /etc/default/grub | grep -vq pstate  ; then 
    echo GRUB_CMDLINE_LINUX=\"\${GRUB_CMDLINE_LINUX} intel_pstate=disable\" >> /etc/default/grub
    update-grub || true # update-grub doesn't exist on redhat.
 #   (date; echo Rebooting...) >> $RUNLAB_STATUS_DIRECTORY/node_status
    reboot
fi

echo -ne  "#!/usr/bin/env bash\n sysctl -w kernel.perf_event_paranoid=-1\n" > /etc/rc.local
chmod a+x /etc/rc.local

## enable access to perf counters

