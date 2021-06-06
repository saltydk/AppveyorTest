sudo su -

USER_NAME=appveyor
BUILD_AGENT_MODE=HyperV
AGENT_DIR=/opt/appveyor/build-agent
USER_HOME=/home/appveyor
APPVEYOR_BUILD_AGENT_VERSION=7.0.3010
LOGGING=false

OS_CODENAME=$(source /etc/os-release && echo $VERSION_CODENAME)
curl -fsSL https://raw.githubusercontent.com/appveyor/build-images/master/scripts/Ubuntu/common.sh -o common.sh
curl -fsSL https://raw.githubusercontent.com/appveyor/build-images/master/scripts/Ubuntu/$OS_CODENAME.sh -o $OS_CODENAME.sh

. common.sh
. $OS_CODENAME.sh

disable_automatic_apt_updates

apt-get update
apt-get -y upgrade
apt-get install -y python

configure_user
install_KVP_packages
install_appveyoragent "$BUILD_AGENT_MODE"

configure_uefi
shutdown now
