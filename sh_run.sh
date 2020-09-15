#!/bin/bash

# Note:
# run as foxconn
# rules/igb.mk has been ignored


# Color Definition
COLOR_TITLE="\e[1;32m"   ### Green ###
COLOR_WARNING="\e[1;33m" ### Yellow ###
COLOR_ERROR="\e[1;31m"   ### Red ###
COLOR_END="\e[0m"        ### END ###

EXEC_FUNC=${1}
BUILD_PLATFORM="${2}"
RELEASE_VERSION=${2}
VENDOR=${2}

function _help {
    echo "========================================================="
    echo "# Description: Help Function"
    echo "========================================================="
    echo "----------------------------------------------------"
    echo "EX       : ${0} help"
    echo "         : ${0} build broadcom"
    echo "         : ${0} build nephos"
    echo "         : ${0} build barefoot"
    echo "         : ${0} build sonic-mgmt"
    echo "         : ${0} build ptf"
    echo "         : ${0} release <version>"
    echo "         : ${0} vendor <vendor>"
    echo "----------------------------------------------------"
}

function _set_release_version {
    echo -ne "${COLOR_TITLE}"
    echo "============================================"
    echo " RELEASE_VERSION=${RELEASE_VERSION}"
    echo "============================================"
    echo -ne "${COLOR_END}"

    GRUB_MENU_PATH="./functions.sh"
    REPLACE_VAR="release_version"
    
    if [ "${RELEASE_VERSION}" == "" ]; then
        echo "RELEASE_VERSION is Empty!!!"
    else
	# replace line
        sed -i "s/${REPLACE_VAR}=.*$/${REPLACE_VAR}=\"${RELEASE_VERSION}\"/g" ${GRUB_MENU_PATH}
    fi
}

function _set_vendor {
    echo -ne "${COLOR_TITLE}"
    echo "============================================"
    echo " VENDOR=${VENDOR}"
    echo "============================================"
    echo -ne "${COLOR_END}"

    GRUB_MENU_PATH="./functions.sh"
    REPLACE_VAR="vendor"
    
    if [ "${VENDOR}" == "" ]; then
        echo "VENDOR is Empty!!!"
    else
	# replace line
        sed -i "s/${REPLACE_VAR}=.*$/${REPLACE_VAR}=\"${VENDOR}\"/g" ${GRUB_MENU_PATH}
    fi
}

function _build_platform {
    echo -ne "${COLOR_TITLE}"
    echo "============================================"
    echo " PLATFORM=${BUILD_PLATFORM}"
    echo "============================================"
    echo -ne "${COLOR_END}"

    if [ "${BUILD_PLATFORM}" == "broadcom" ]; then
        make init
        make configure PLATFORM=broadcom
        BLDENV=stretch make stretch
        make target/sonic-broadcom.bin
    elif [ "${BUILD_PLATFORM}" == "nephos" ]; then
        make init
        make configure PLATFORM=nephos
        BLDENV=stretch make stretch
        make target/sonic-nephos.bin
    elif [ "${BUILD_PLATFORM}" == "barefoot" ]; then
        make init
        ls patch-331866db/ -I readme.txt | xargs cp -rf -t ./
        make configure PLATFORM=barefoot
        BLDENV=stretch make stretch
        make target/sonic-barefoot.bin
    elif [ "${BUILD_PLATFORM}" == "sonic-mgmt" ]; then
        make init
        make configure PLATFORM=generic
        BLDENV=stretch make stretch
        make target/docker-sonic-mgmt.gz
    elif [ "${BUILD_PLATFORM}" == "ptf" ]; then
        make init
        make configure PLATFORM=generic
        BLDENV=stretch make stretch
        make target/docker-ptf.gz
    else
        echo "not supported platform!!! exit!!!"
        exit 0
    fi
}

function _main {
    start_time_str=`date`
    start_time_sec=$(date +%s)

    user=`whoami`
    echo "user: ${user}"

    if [ "${user}" == "root" ]; then
        echo "not allow user ${user} to run this script, exit!!"
        exit 0;
    fi
    
    if [ "${EXEC_FUNC}" == "help" ]; then 
        _help
    elif [ "${EXEC_FUNC}" == "build" ]; then
        _build_platform
    elif [ "${EXEC_FUNC}" == "release" ]; then
        _set_release_version
    elif [ "${EXEC_FUNC}" == "vendor" ]; then
        _set_vendor
    else
        _help
    fi  
    
    end_time_str=`date`
    end_time_sec=$(date +%s)
    diff_time=$[ ${end_time_sec} - ${start_time_sec} ]
    echo "Start Time: ${start_time_str} (${start_time_sec})"
    echo "End Time  : ${end_time_str} (${end_time_sec})"
    echo "Total Execution Time: ${diff_time} sec"

    echo "done!!!"
}

_main
