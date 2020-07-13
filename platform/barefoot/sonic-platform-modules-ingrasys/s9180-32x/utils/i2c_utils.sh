#!/bin/bash

# Copyright (C) 2017 Ingrasys, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# trun on for more debug output
#DEBUG="on"

VERSION="1.1.0"

EXEC_FUNC=${1}
ALL_PARA=$@

############################################################
# Distributor ID: Debian
# Description:    Debian GNU/Linux 8.6 (jessie)
# Release:        8.6
# Codename:       jessie
# Linux debian 3.16.0-4-amd64 #1
# SMP Debian 3.16.36-1+deb8u1 (2016-09-03) x86_64 GNU/Linux
############################################################

# Color Definition
COLOR_TITLE="\e[1;32m"   ### Green ###
COLOR_WARNING="\e[1;33m" ### Yellow ###
COLOR_ERROR="\e[1;31m"   ### Red ###
COLOR_END="\e[0m"        ### END ###

NUM_I801_DEVICE=0 # Main I2C
NUM_MUX1_CHAN0_DEVICE=$(( ${NUM_I801_DEVICE} + 1 ))  # zQSFP I/O 0-7
NUM_MUX1_CHAN1_DEVICE=$(( ${NUM_MUX1_CHAN0_DEVICE} + 1 ))  # zQSFP I/O 8-15
NUM_MUX1_CHAN2_DEVICE=$(( ${NUM_MUX1_CHAN1_DEVICE} + 1 ))  # zQSFP I/O 16-23
NUM_MUX1_CHAN3_DEVICE=$(( ${NUM_MUX1_CHAN2_DEVICE} + 1 ))  # zQSFP I/O 24-31
NUM_MUX1_CHAN4_DEVICE=$(( ${NUM_MUX1_CHAN3_DEVICE} + 1 ))  # zQSFP I/O ABS#, INT
NUM_MUX1_CHAN5_DEVICE=$(( ${NUM_MUX1_CHAN4_DEVICE} + 1 ))  # zQSFP I/O LPMODE, RST, MODSEL
NUM_MUX1_CHAN6_DEVICE=$(( ${NUM_MUX1_CHAN5_DEVICE} + 1 ))  # MAC CLK CPLD
NUM_MUX1_CHAN7_DEVICE=$(( ${NUM_MUX1_CHAN6_DEVICE} + 1 ))  # P1V0 PWR
NUM_MUX3_CHAN0_DEVICE=$(( ${NUM_MUX1_CHAN7_DEVICE} + 1 )) # zQSFP I/O 0-7
NUM_MUX4_CHAN0_DEVICE=$(( ${NUM_MUX3_CHAN0_DEVICE} + 8 )) # zQSFP I/O 8-15
NUM_MUX5_CHAN0_DEVICE=$(( ${NUM_MUX4_CHAN0_DEVICE} + 8 )) # zQSFP I/O 16-23
NUM_MUX6_CHAN0_DEVICE=$(( ${NUM_MUX5_CHAN0_DEVICE} + 8 )) # zQSFP I/O 24-31
NUM_MUX7_CHAN0_DEVICE=$(( ${NUM_MUX6_CHAN0_DEVICE} + 8 )) # Temp Sensor 0x48-0x4D
NUM_MAIN_MUX_CHAN0_DEVICE=$(( ${NUM_MUX7_CHAN0_DEVICE} + 8 )) # System LED HWMON
NUM_MAIN_MUX_CHAN1_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 1 )) # System LED
NUM_MAIN_MUX_CHAN2_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 2 )) # Board ID
NUM_MAIN_MUX_CHAN3_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 3 )) # MAX_Slave
NUM_MAIN_MUX_CHAN4_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 4 )) # TEMP Sensor
NUM_MAIN_MUX_CHAN5_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 5 )) # CLK GEN
NUM_MAIN_MUX_CHAN6_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 6 )) # VDD CORE
NUM_MAIN_MUX_CHAN7_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 7 )) # HWMON
NUM_FRU_MUX_CHAN0_DEVICE=$(( ${NUM_MAIN_MUX_CHAN0_DEVICE} + 8 )) # PSU2
NUM_FRU_MUX_CHAN1_DEVICE=$(( ${NUM_FRU_MUX_CHAN0_DEVICE} + 1 )) # PSU1
NUM_FRU_MUX_CHAN2_DEVICE=$(( ${NUM_FRU_MUX_CHAN0_DEVICE} + 2 )) # FAN
NUM_CPLD_DEVICE=$(( ${NUM_MUX7_CHAN0_DEVICE} + 3 )) # CPLD
NUM_SFP1_DEVICE=$(( ${NUM_MUX7_CHAN0_DEVICE} + 4 )) # CPLD
NUM_SFP2_DEVICE=$(( ${NUM_MUX7_CHAN0_DEVICE} + 5 )) # CPLD
NUM_ROV_DEVICE=${NUM_MAIN_MUX_CHAN6_DEVICE}

# i2c sys path
PATH_SYS_I2C_DEVICES="/sys/bus/i2c/devices"

# i2c address for deviecs
MAIN_MUX_I2C_ADDR=0x76

UTIL_PATH="/usr/sbin"
BMC_UTIL="i2c_utils_bmc.sh"
NOBMC_UTIL="i2c_utils_nobmc.sh"
WRAP_UTIL="i2c_utils_wrap.sh"

SHARE_PATH="/usr/share/sonic/device/x86_64-ingrasys_s9180_32x-r0"

NOBMC_FANCTL="fancontrol.nobmc"
FANCTL_CFG="fancontrol"

NOBMC_SENSORS="sensors_nobmc.conf"
SENSORS_CFG="sensors.conf"

PLUGIN_PATH="$SHARE_PATH/plugins"
BMC_PSUUTIL="psuutil.py.bmc"
NOBMC_PSUUTIL="psuutil.py.nobmc"
PSUUTIL="psuutil.py"
PSUUTIL_PYC="psuutil.pyc"

# bmc flag
BMC_ENABLE=0

function _adapt_bmc_enable  {

    # check the link target to identify current state
    res=`readlink -e ${UTIL_PATH}/${WRAP_UTIL} | grep ${BMC_UTIL}`
    adapt_change=0
    
    if [ -z $res ]; then
        # the link target not exist or not bmc enable target
        adapt_change=1
    else
        echo "no change needed for bmc enable"
    fi
    
    # need to adapt the chagne for bmc enable
    ((adapt_change)) && {
        echo "adapting change ..."
        # change utils script link target
        rm -rf ${UTIL_PATH}/${WRAP_UTIL}
        ln -s ${UTIL_PATH}/${BMC_UTIL} ${UTIL_PATH}/${WRAP_UTIL}
        # remove sensors config
        rm -f ${SHARE_PATH}/${SENSORS_CFG}
        # remove fancontrol config
        rm -f ${SHARE_PATH}/${FANCTL_CFG}
        # change plugin python script for psuutil
        rm -f ${PLUGIN_PATH}/${PSUUTIL_PYC}
        cp -f ${PLUGIN_PATH}/${BMC_PSUUTIL} ${PLUGIN_PATH}/${PSUUTIL}     
        # restart docker pmon if it is already running
        exist=`docker ps | grep pmon`
        if [ ! -z "${exist}" ]; then
            docker restart pmon
        fi
        
    }
}

function _adapt_bmc_disable  {
    
    # check the link target to identify current state
    res=`readlink -e ${UTIL_PATH}/${WRAP_UTIL} | grep ${NOBMC_UTIL}`
    adapt_change=0
    
    if [ -z $res ]; then
        # the link target not exist or bmc enable target
        adapt_change=1
    else
        echo "no change needed for bmc disable"
    fi
    
    # need to adapt the chagne for bmc enable
    ((adapt_change)) && {
        echo "adapting change ..."
        # change utils script link target
        rm -rf ${UTIL_PATH}/${WRAP_UTIL}
        ln -s ${UTIL_PATH}/${NOBMC_UTIL} ${UTIL_PATH}/${WRAP_UTIL}
        # change sensors config
        cp -f ${SHARE_PATH}/${NOBMC_SENSORS} ${SHARE_PATH}/${SENSORS_CFG}
        # change fancontrol config
        cp -f ${SHARE_PATH}/${NOBMC_FANCTL} ${SHARE_PATH}/${FANCTL_CFG}
        # change plugin python script for psuutil
        rm -f ${PLUGIN_PATH}/${PSUUTIL_PYC}
        cp -f ${PLUGIN_PATH}/${NOBMC_PSUUTIL} ${PLUGIN_PATH}/${PSUUTIL}
        # restart docker pmon if it is already running
        exist=`docker ps | grep pmon`
        if [ ! -z ${exist} ]; then
            docker restart pmon
        fi
    }
}

function _check_bmc_enable {
    # init for i2c access
    modprobe i2c_i801
    modprobe i2c_dev
    
    # check if sysfs already exist for main mux, if yes, bmc not enabled
    if [ -e "${PATH_SYS_I2C_DEVICES}/i2c-${NUM_MAIN_MUX_CHAN0_DEVICE}" ]; then 
        echo "BMC NOT enabled"
        BMC_ENABLE=0
        return
    fi   

    # sysfs not exist, check if main mux accessable, if no, bmc enabled
    i2cget -y ${NUM_I801_DEVICE} ${MAIN_MUX_I2C_ADDR} 0 2>/dev/null
    result=$?
    if [ $result -eq 0 ]; then 
        echo "BMC NOT enabled"
        BMC_ENABLE=0
    else 
        echo "BMC enabled"
        BMC_ENABLE=1
    fi   
}

#I2C Init wrap
function _i2c_init_wrap {
    echo "========================================================="
    echo "# Description: I2C wrap Init"
    echo "========================================================="

    _check_bmc_enable

    if ((BMC_ENABLE)); then
        _adapt_bmc_enable
    else
        _adapt_bmc_disable
    fi
    
    # continue i2c_init from correct script
    ${UTIL_PATH}/${WRAP_UTIL} ${EXEC_FUNC}
}

#Main Function
function _main {
    # only init command handle here, others will handled by targer script 
    if [ "${EXEC_FUNC}" == "i2c_init" ]; then
        _i2c_init_wrap
    else
        if [ -f ${UTIL_PATH}/${WRAP_UTIL} ]; then
            ${UTIL_PATH}/${WRAP_UTIL} ${ALL_PARA}
        else
            echo "incorrect init for bmc support"
        fi
    fi
}

_main
