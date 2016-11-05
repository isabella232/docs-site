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


# Builds a version menu ('json-versions.js') and 'version' file from a configuration file.
# The configuration file is specific for the product (cdap, coopr, tigon).
# The resulting version menu is a JavaScript file, placed in the product directory on the web server.
# The 'version' file is a text file with the current version, placed in the product directory on the web server.

cd $(cd $(dirname ${BASH_SOURCE[0]}); pwd -P)

JSON_VERSIONS_JS="json-versions.js"
SCRIPT=`basename $0`
SCRIPT_PATH=$(pwd -P)
TYPES="cdap coopr tigon"

function usage() {
  echo "Building script for version menu for documentation."
  echo
  echo "Usage: ${SCRIPT} <option>"
  echo
  echo "  Options (select one):"
  echo "    build-jsons-all    Builds the json-versions.js and version for the types"
  echo "                       and outputs them to that type's top-level directory:"
  echo "                       ${TYPES}"
  echo
  echo "    build-json <type>  Builds the json-versions.js and version for a particular type"
  echo "                       and outputs them to that type's top-level directory:"
  echo "                       one of ${TYPES}"
  echo
  echo "    help               This usage statement"
  echo
}

function die() {
  echo
  echo "ERROR: ${*}"
  echo
  exit 1
}

function build_jsons() {
  local warnings
  for type in ${TYPES}; do
    build_json_js ${type}
    warnings=$?
    if [[ ${warnings} -ne 0 ]]; then
      return ${warnings}
    fi
  done
  return ${warnings}
}

function build_json_js() {
  local warnings
  local type=${1}
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
  return ${warnings}
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

case "${1}" in
  build-jsons-all ) build_jsons;;
  build-json )      build_json_js ${2};;
  help )            usage; exit 0;;
  * )               usage; exit 1;;
esac

exit $?
