#!/usr/bin/env bash

# Copyright © 2016 Cask Data, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Calls a Python script that builds a version menu ('json-versions.js') and 'version' file from a configuration file.
# The configuration file is specific for the product (cdap, coopr, tigon).
# The resulting version menu is a JavaScript file, placed in the product directory on the web server.
# The 'version' file is a text file with the current version, placed in the product directory on the web server.

cd $(cd $(dirname ${BASH_SOURCE[0]}); pwd -P)

JSON_VERSIONS_JS="json-versions.js"
SCRIPT=$(basename $0)
SCRIPT_PATH=$(pwd -P)
TYPES=$(cd ${SCRIPT_PATH}/../configs; ls -1 | sed -e 's/.txt//')

function usage() {
  echo "Building script for version menu for documentation."
  echo
  echo "Usage: ${SCRIPT} type"
  echo
  echo "Where type is one of:"
  echo
  echo "all"
  echo "${TYPES}"
  echo
  echo "  If 'all' is specified, builds the json-versions.js and version for all of the types"
  echo "  and outputs them to each type's top-level directory."
  echo
  echo "  If a <type> is specified, builds the json-versions.js and version for that type"
  echo "  and outputs them to that type's top-level directory."
  echo
  echo "  In both cases, any intermediate directories required are created."
  echo
}

function die() {
  echo
  echo "ERROR: ${*}"
  echo
  usage
  exit 1
}

function build_jsons() {
  local warnings
  for type in ${@}; do
    if [[ -z ${type} ]]; then
      die "Type needs to be provided."
    fi
    echo "Building type '${type}'"
    cd ${SCRIPT_PATH}  
    python builder.py "${SCRIPT_PATH}/../configs/${type}.txt" "${SCRIPT_PATH}/../www/${type}/${JSON_VERSIONS_JS}"
    warnings=$?
    if [[ ${warnings} -eq 0 ]]; then
      echo "Wrote '${JSON_VERSIONS_JS}' and 'version' file for type ${type}"
      echo
    fi
  done
  return ${warnings}
}

function build_json_js() {
  __list=${1:-${TYPES}}
  build_jsons ${__list}
}

if [ $# -lt 1 ]; then
  usage
  exit 0
fi

case "${1}" in
  all )  build_json_js; exit $?;;
  *   )  build_json_js ${1}; exit $?;;
esac
