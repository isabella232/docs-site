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

__site=$(cd $(cd $(dirname ${BASH_SOURCE[0]}); pwd -P); cd $(pwd -P)/.. ; pwd -P)  # traverse symlinks, etc
__types=${@:-$(cd "${__site}/configs"; ls -1 | sed -e 's/.txt$//')} # support multiple types

rm -rf ${__site}/target || ( echo "Could not remove target directory" ; exit 1)
mkdir ${__site}/target || ( echo "Could not create target directory" ; exit 1)
cp -R ${__site}/www ${__site}/target/www || ( echo "Could not copy www to target directory" ; exit 1)

for __type in ${__types}; do
  python "${__site}/scripts/builder.py" \
    "${__site}/configs/${__type}.txt" \
    "${__site}/target/www/${__type}/json-versions.js" || (
      echo "Could not create 'json-versions.js' and 'version' file for ${__type}" ; exit 1)
done

zip -qr ${__site}/target/www.zip ${__site}/target/www/* --exclude *.DS_Store* *.buildinfo*
