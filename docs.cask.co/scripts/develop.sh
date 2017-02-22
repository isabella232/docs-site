#!/usr/bin/env bash

# Copyright © 2017 Cask Data, Inc.
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

# Calls the build.sh script that builds from a configuration file.
# Copies over a sample numbered directory and an .htaccess file to allow for local testing with an Apache server.

function die() {
  echo ${@}; exit 1;
}

./build.sh

__site=$(cd $(cd $(dirname ${BASH_SOURCE[0]}); pwd -P); cd $(pwd -P)/.. ; pwd -P)  # traverse symlinks, etc

cp -R ${__site}/www_develop/cdap/* ${__site}/target/www/cdap || die "Could not copy www_develop/cdap/* to target directory"
cp ${__site}/www_develop/htaccess  ${__site}/target/www/.htaccess || die "Could not copy www_develop/htaccess to target/www/.htaccess"

echo "Copied development files www/cdap/2.7.1 and www/.htaccess"
