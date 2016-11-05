==========================
docs.cask.co Documentation
==========================

configs
=======
A simple configuration file that maps to product types and sub-directories in the web site::

  cdap.txt
  coopr.txt
  tigon.txt
  
Instructions for configuring the file are in each file.


www
===
Top-level directory, to be mapped to the web server.

This is intended for Amazon S3.

Exclude these directories from syncing::

  www/cdap/current
  www/coopr/current
  www/tigon/current

as they are copies used to test the menus when the configuration file has been generated.


scripts
=======
Script used to create the JSON and timeline from the configuration files (conf.txt) in these directories::

  www/cdap/json-versions.js
  www/coopr/json-versions.js
  www/tigon/json-versions.js

Run ``build.sh`` to generate the JSON (for menu and timeline), and update the version file, such as::

  $ ./build.sh build-json cdap
  
To generate all JSONs and version files, use::

  $ ./build.sh build-jsons-all


Copyright
=========
Copyright © 2016 Cask Data, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
