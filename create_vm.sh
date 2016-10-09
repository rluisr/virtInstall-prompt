#!/bin/bash -eu
stty erase ^H

readonly CURRENT_PATH=$(cd $(dirname $0) && pwd)
. ${CURRENT_PATH}/lib/function.sh

if [ $# -eq 0 ]; then
  prepare_setup
  show_specs

  green "Are you sure you want to install? [y/N]: "
  while read value
  do
    case ${value} in
      "y" | "Y" ) setup ;;
      "n" | "N" ) red "Cancelled."; exit 1 ;;
      * ) continue ;;
    esac
  done

elif [ $# -gt 0 ]; then
  case $1 in
    "-v" | "--version" ) version ;;
    "-h" | "--help" ) usage ;;
    * ) usage ;;
  esac
fi
