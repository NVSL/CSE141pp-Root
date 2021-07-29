#!/bin/bash

###############################################################################
#	This script sets up a packet server
###############################################################################

set -x #print out commands as we execute them.
set -v

#. $CONFIG_REPO_ROOT/funcs.sh

if [ "$APTGET." = "." ]; then
    APTGET=apt-get
fi

mkdir -p /tmp/cse142L-install
cd /tmp/cse142L-install

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
    $APTGET install \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    gnupg \
	    lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
	"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    $APTGET install docker-ce docker-ce-cli containerd.io
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

pushd $INSTALL_ROOT
make pull
popd 

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

$APTGET -y install kmod linux-headers-generic build-essential linux-headers-$(uname -r)

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

## enable access to perf counters
sysctl -w kernel.perf_event_paranoid=-1
