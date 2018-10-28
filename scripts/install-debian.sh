#!/bin/bash
#
# Install a VLMCSD service for Debian/Ubuntu
#
# Author: Wind4 (puxiaping@gmail.com)
# Date:   November 30, 2015
#

check_result() {
  if [ $1 -ne 0 ]; then
    echo "Error: $2" >&2
    exit $1
  fi
}

if [ "x$(id -u)" != 'x0' ]; then
  echo 'Error: This script can only be executed by root'
  exit 1
fi

if [ -f '/etc/init.d/vlmcsd' ]; then
  echo 'VLMCSD service has been installed.'
  exit 1
fi

if [ ! -f '/usr/bin/wget' ]; then
  echo 'Installing wget ...'
  apt-get -qq update
  apt-get -qq install -y wget
  check_result $? "Can't install wget."
  echo 'Install wget succeed.'
fi

TMP_DIR=`mktemp -d`
GIT_TAGS=svn1112
cd ${TMP_DIR}

echo 'Downloading vlmcsd binaries ...'
wget -q https://github.com/Wind4/vlmcsd/releases/download/${GIT_TAGS}/binaries.tar.gz -O binaries.tar.gz
check_result $? 'Download vlmcsd failed.'

echo 'Downloading startup script ...'
wget -q https://wind4.github.io/vlmcsd/scripts/init.d/vlmcsd-debian -O vlmcsd.init
check_result $? 'Download startup script failed.'

echo 'Extract vlmcsd ...'
tar zxf binaries.tar.gz
cp binaries/Linux/intel/static/vlmcsd-x86-musl-static /usr/bin/vlmcsd
cp vlmcsd.init /etc/init.d/vlmcsd

echo 'Fix Permissions ...'
chmod 755 /usr/bin/vlmcsd
chown root.root /usr/bin/vlmcsd
chmod 755 /etc/init.d/vlmcsd
chown root.root /etc/init.d/vlmcsd

echo 'Configuring deamon ...'
update-rc.d vlmcsd defaults
service vlmcsd start
check_result $? 'Installation failed.'

echo 'Cleaning ...'
rm -rf ${TMP_DIR}

echo 'Installed successfully.'
