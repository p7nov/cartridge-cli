#!/bin/bash
set -e

EXAMPLE_DIR=$1
WD=$(pwd)
RUN_DIR=/tmp/cartridge_example_test

cp ./check_instances.lua ${EXAMPLE_DIR}/check_instances_http.lua
cd ${EXAMPLE_DIR}

tarantoolctl rocks make
tarantoolctl rocks install cartridge-cli
tarantoolctl rocks install luatest

export PATH=$(pwd)/.rocks/bin/:$PATH

mkdir -p ${RUN_DIR}
cartridge start --cfg demo.yml --run_dir ${RUN_DIR}

echo "Check instances... "
tarantool check_instances_http.lua \
    && export TNT_GSE_STATUS="Success" \
    || export TNT_GSE_STATUS=""

if [[ "$TNT_GSE_STATUS" ]]; then
    echo "\t\033[0;32mSuccess\033[0m"
else 
    echo "\t\033[0;31mFailed\033[0m"
fi

cartridge stop --cfg demo.yml --run_dir ${RUN_DIR}
rm check_instances_http.lua
cd ${WD}

if [[ -z "$TNT_GSE_STATUS" ]]; then
    echo "API access error"
    exit 1
fi
