#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -ex
export OPERA_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
CONF_DIR=${OPERA_DIR}/conf
OPENO_DIR=${OPERA_DIR}/open-o
JUJU_DIR=${OPERA_DIR}/juju
WORK_DIR=${OPERA_DIR}/work
UTIL_DIR=${OPERA_DIR}/util

export DEPLOY_FIRST_TIME=${DEPLOY_FIRST_TIME:-"true"}
source ${OPERA_DIR}/prepare.sh
generate_conf
source ${OPERA_DIR}/conf/download.conf
source ${WORK_DIR}/scripts/openo-vm.conf
source ${WORK_DIR}/scripts/network.conf

source ${UTIL_DIR}/log.sh
source ${OPENO_DIR}/openo_vm.sh
source ${JUJU_DIR}/adapter.sh
source ${JUJU_DIR}/juju_setup.sh
source ${JUJU_DIR}/juju_launch.sh

mkdir -p $WORK_DIR

if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then
    package_prepare
    network_prepare
    generate_compass_openrc
fi

source $WORK_DIR/admin-openrc.sh

if ! openo_download_iso; then
    log_error "openo_download_iso failed"
    exit 1
fi

if ! launch_openo_vm; then
    log_error "launch_openo_vm failed"
    exit 1
fi

if ! launch_openo_docker; then
    log_error "launch_openo_docker failed"
    exit 1
fi

juju_env_prepare

if ! juju_prepare; then
    log_error "launch_openo_docker failed"
    exit 1
fi

if ! launch_juju; then
    log_error "launch_juju failed"
    exit 1
fi

figlet -ctf slant Open-O Installed!
set +ex
