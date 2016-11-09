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
TARGET_PATH=$(cd "${SCRIPT_PATH}/../target"; pwd -P)
WWW_PATH=$(cd "${SCRIPT_PATH}/../www"; pwd -P)

function usage() {
  echo "Building script for support files for documentation."
  echo
  echo "Usage: ${SCRIPT} type"
  echo
  echo "Where type is one of:"
  echo
  echo "test"
  echo "all"
  echo "${TYPES}"
  echo
  echo "  If 'test' is specified, builds the json-versions.js and version for all of the types,"
  echo "  outputs them to each type's top-level directory in the target directory, and copies"
  echo "  sufficient appropriate file(s) that the results can be checked."
  echo "  Copies files from ${WWW_PATH}"
  echo "  Intended for manual use by Release Managers so that the config(s) can be tested for accuracy."
  echo
  echo "  If 'all' is specified, builds the json-versions.js and version for all of the types,"
  echo "  and outputs them to each type's top-level directory in the target directory."
  echo "  Intended for use by Bamboo build plans."
  echo
  echo "  If a <type> is specified, builds the json-versions.js and version for that type,"
  echo "  and outputs them to that type's top-level directory in the target directory."
  echo
  echo "  In all cases, the target directory is cleaned first and intermediate directories required are created."
  echo "  Writes all files to ${TARGET_PATH}"
  echo
}

function die() {
  echo
  echo "ERROR: ${*}"
  echo
  exit 1
}

function clean_target() {
  rm -rf ${TARGET_PATH}
  mkdir ${TARGET_PATH}
  warnings=$?
  if [[ ${warnings} -eq 0 ]]; then
    echo "Cleaned ${TARGET_PATH} directory"
    echo
  else
    echo "Could not clean ${TARGET_PATH} directory"
  fi
  return ${warnings}
}

function build_test() {
  local warnings
  clean_target
  if [[ ${warnings} -ne 0 ]]; then
    return ${warnings}
  fi
  cp -R ${WWW_PATH}/* ${TARGET_PATH}
  warnings=$?
  if [[ ${warnings} -ne 0 ]]; then
    return ${warnings}
  fi
  _build_json ${TYPES}
}

function build_jsons() {
  local warnings
  clean_target
  if [[ ${warnings} -ne 0 ]]; then
    return ${warnings}
  fi
  if [[ -z ${@} ]]; then
    die "Type needs to be provided."
  fi
  _build_json ${@}
}

function _build_json() {
  local warnings
  for type in ${@}; do
    echo "Building type '${type}'"
    cd ${SCRIPT_PATH}  
    python builder.py "${SCRIPT_PATH}/../configs/${type}.txt" "${TARGET_PATH}/${type}/${JSON_VERSIONS_JS}"
    warnings=$?
    if [[ ${warnings} -eq 0 ]]; then
      echo "Wrote '${JSON_VERSIONS_JS}' and 'version' file for type '${type}'"
      echo
    else
      echo "Could not create '${JSON_VERSIONS_JS}' and 'version' file for type '${type}'"
      return ${warnings}
    fi
  done
  return ${warnings}
}

if [ $# -lt 1 ]; then
  usage
  exit 0
fi

case "${1}" in
  all  )  build_jsons ${TYPES}; exit $?;;
  test )  build_test ${TYPES}; exit $?;;
  *    )  build_jsons ${1}; exit $?;;
esac
