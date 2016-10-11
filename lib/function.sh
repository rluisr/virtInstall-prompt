#!/bin/bash -eu

readonly VERSION=0.1

NORMAL=$(tput sgr0)
WHITE=$(tput setaf 7; tput bold)
GREEN=$(tput setaf 2; tput bold)
BLUE=$(tput setaf 4; tput bold)
YELLOW=$(tput setaf 3; tput bold)
RED=$(tput setaf 1; tput bold)

white() {
  echo -e "$WHITE$*$NORMAL"
}

red() {
  echo -e "$RED$*$NORMAL"
}

green() {
  echo -e "$GREEN$*$NORMAL"
}

yellow() {
  echo -e "$YELLOW$*$NORMAL"
}

blue() {
  echo -e "$BLUE$*$NORMAL"
}

checkOS() {
  if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then                                                                                           
  OS='Cygwin'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi
}

usage() {
  cat <<EOF
  $(basename ${0}) is tool for creating new virtual machine with prompt.

  Usage:
      $(basename ${0}) [<options>]

  Options:
      --version, -v     print $(basename ${0}) version
      --help, -h        print this
EOF

  exit 1
}

version() {
  echo "$(basename ${0}) version 0.1"
  exit 1
}

prepare_setup() {
  blue "Start creating new virtual machines..."
  red "If you don't set parameter don't 'Enter' set 'none'."

  define_specs "name" "CentOS"
  define_specs "vcpus" "4"
  define_specs "arch" "x86_64"
  define_specs "ram" "1024"
  define_specs "disk_path" "/mnt/images/hello.qcow2 / none"
  define_specs "disk_pool" "default,size=5,format=qcowa / none"
  define_specs "os_type" "linux"
  define_specs "os_variant" "rhel7"
  define_specs "network" "bridge=br0 / network=default"
  define_specs "graphics" "none"
  define_specs "console" "pty"
  define_specs "serial" "pty"
  define_specs "location" "/iso/CentOS.iso"
  define_specs "initrd_inject" "/tmp/centos.ks.cfg / none"
  define_specs "extra_args" "inst.ks=file:/centos7.ks.cfg console=ttyS0"
}

define_specs() {
  echo -n "--${1} [${2}]: "
  while read value
  do
    if [ "${value}" == "" ]; then
      eval "$1"="'$2'"
      readonly eval "$1"
    else
      eval "$1"="'${value}'"
      readonly eval "$1"
    fi

    break
  done
}

show_specs() {
  echo -e ""
  echo -e ""
  echo -e ""
  echo -e "----------------------------------------"
  echo -e "--name: ${name}"
  echo -e "--vcpus: ${vcpus}"
  echo -e "--arch: ${arch}"
  echo -e "--ram: ${ram}"
  echo -e "--disk path: ${disk_path}"
  echo -e "--disk pool: ${disk_pool}"
  echo -e "--os-type: ${os_type}"
  echo -e "--os-variant: ${os_variant}"
  echo -e "--network: ${network}"
  echo -e "--graphics: ${graphics}"
  echo -e "--console: ${console}"
  echo -e "--serial: ${serial}"
  echo -e "--location: ${location}"
  echo -e "--initrd-inject: ${initrd_inject}"
  echo -e "--extra-args: ${extra_args}"
  echo -e "----------------------------------------"
}

setup() {
  [ ${disk_path} = "none" ] && [ ${disk_pool} != "none" ] && exec="virt-install --name ${name} --vcpus ${vcpus} --ram ${ram} --arch ${arch} --os-type ${os_type} --os-variant ${os_variant} --disk ${disk_pool} --network ${network} --graphics ${graphics} --console ${console} --serial ${serial} --location ${location} --extra-args '${extra_args}'"
  [ ${disk_path} != "none" ] && [ ${disk_pool} = "none" ] && exec="virt-install --name ${name} --vcpus ${vcpus} --ram ${ram} --arch ${arch} --os-type ${os_type} --os-variant ${os_variant} --disk ${disk_path} --network ${network} --graphics ${graphics} --console ${console} --serial ${serial} --location ${location} --extra-args '${extra_args}'"

  [ ${initrd_inject} != "none" ] && exec="${exec} --initrd-inject ${initrd_inject}" || :

  eval ${exec}
}
