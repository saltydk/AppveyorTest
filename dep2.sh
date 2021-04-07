#!/bin/sh
#################################################################################
# Title:         Cloudbox: Dependencies Installer                               #
# Author(s):     L3uddz, Desimaniac, EnorMOZ                                    #
# URL:           https://github.com/Cloudbox/Cloudbox                           #
# Description:   Installs dependencies needed for Cloudbox.                     #
# --                                                                            #
#             Part of the Cloudbox project: https://cloudbox.works              #
#################################################################################
#                     GNU General Public License v3.0                           #
#################################################################################

################################
# Privilege Escalation
################################

# Restart script in SUDO
# https://unix.stackexchange.com/a/28793

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

################################
# Variables
################################

VERBOSE=true

readonly SYSCTL_PATH="/etc/sysctl.conf"
readonly PYTHON_CMD_SUFFIX="-m pip install \
                              --no-cache-dir \
                              --disable-pip-version-check \
                              --upgrade"
readonly PYTHON3_CMD="python3 $PYTHON_CMD_SUFFIX"
readonly PYTHON2_CMD="python $PYTHON_CMD_SUFFIX"
readonly PIP="21.0.1"
readonly ANSIBLE=">=2.9,<2.10"

################################
# Argument Parser
################################

while getopts 'v' f; do
    case $f in
    v)	VERBOSE=true;;
    esac
done

################################
# Main
################################

$VERBOSE || exec &>/dev/null

## Disable IPv6
if [ -f "$SYSCTL_PATH" ]; then
    ## Remove 'Disable IPv6' entries from systctl
    sed -i -e '/^net.ipv6.conf.all.disable_ipv6/d' "$SYSCTL_PATH"
    sed -i -e '/^net.ipv6.conf.default.disable_ipv6/d' "$SYSCTL_PATH"
    sed -i -e '/^net.ipv6.conf.lo.disable_ipv6/d' "$SYSCTL_PATH"
    sysctl -p
fi

## Environmental Variables
export DEBIAN_FRONTEND=noninteractive

## Install Pre-Dependencies
apt-get install -y --reinstall \
    software-properties-common \
    apt-transport-https
apt-get update

## Add apt repos
add-apt-repository main
add-apt-repository universe
add-apt-repository restricted
add-apt-repository multiverse
apt-get update

## Install apt Dependencies
apt-get install -y --reinstall \
    nano \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    python3-apt \
    python-dev \
    python-pip \
    python-apt

## Install pip3 Dependencies
$PYTHON3_CMD \
    pip==${PIP}
$PYTHON3_CMD \
    setuptools
$PYTHON3_CMD \
    pyOpenSSL \
    requests \
    netaddr \
    jmespath \
    ansible$ANSIBLE

## Install pip2 Dependencies
$PYTHON2_CMD \
    pip==${PIP}
$PYTHON2_CMD \
    setuptools
$PYTHON2_CMD \
    pyOpenSSL \
    requests \
    netaddr \
    jmespath

## Copy /usr/local/bin/pip to /usr/bin/pip
[ -f /usr/local/bin/pip ] && cp /usr/local/bin/pip /usr/bin/pip
[ -f /usr/local/bin/pip3 ] && cp /usr/local/bin/pip3 /usr/bin/pip3
