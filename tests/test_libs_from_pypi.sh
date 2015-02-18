#!/usr/bin/env bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.


TOP=$(cd $(dirname "$0")/.. && pwd)

export TOP_DIR=$TOP

# we don't actually care about the HOST_IP
HOST_IP="don't care"
# Import common functions
source $TOP/functions
source $TOP/stackrc
source $TOP/lib/tls
for i in $TOP/lib/*; do
    if [[ -f $i ]]; then
        source $i
    fi
done

ALL_LIBS="python-novaclient oslo.config pbr oslo.context python-troveclient python-keystoneclient taskflow oslo.middleware pycadf python-glanceclient python-ironicclient tempest-lib oslo.messaging oslo.log cliff python-heatclient stevedore python-cinderclient glance_store oslo.concurrency oslo.db oslo.vmware keystonemiddleware oslo.serialization python-saharaclient django_openstack_auth python-openstackclient oslo.rootwrap oslo.i18n python-ceilometerclient oslo.utils python-swiftclient python-neutronclient tooz ceilometermiddleware"

# Generate the above list with
# echo ${!GITREPO[@]}

function check_exists {
    local thing=$1
    local hash=$2
    local key=$3
    if [[ ! -z "$VERBOSE" ]]; then
        echo "Checking for $hash[$key]"
    fi
    if [[ -z $thing ]]; then
        echo "$hash[$key] does not exit!"
        exit 1
    else
        if [[ ! -z "$VERBOSE" ]]; then
            echo "$hash[$key] => $thing"
        fi
    fi
}

function test_all_libs_upto_date {
    # this is all the magics
    local found_libs=${!GITREPO[@]}
    declare -A all_libs
    for lib in $ALL_LIBS; do
        all_libs[$lib]=1
    done

    for lib in $found_libs; do
        if [[ -z ${all_libs[$lib]} ]]; then
            echo "Library '$lib' not listed in unit tests, please add to ALL_LIBS"
            exit 1
        fi

    done
    echo "test_all_libs_upto_date PASSED"
}

function test_libs_exist {
    local lib=""
    for lib in $ALL_LIBS; do
        check_exists "${GITREPO[$lib]}" "GITREPO" "$lib"
        check_exists "${GITBRANCH[$lib]}" "GITBRANCH" "$lib"
        check_exists "${GITDIR[$lib]}" "GITDIR" "$lib"
    done

    echo "test_libs_exist PASSED"
}

function test_branch_master {
    for lib in $ALL_LIBS; do
        if [[ ${GITBRANCH[$lib]} != "master" ]]; then
            echo "GITBRANCH for $lib not master (${GITBRANCH[$lib]})"
            exit 1
        fi
    done

    echo "test_branch_master PASSED"
}

set -o errexit

test_libs_exist
test_branch_master
test_all_libs_upto_date
