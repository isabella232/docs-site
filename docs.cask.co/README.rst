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

These directories are excluded from syncing::

  www/cdap/current
  www/coopr/current
  www/tigon/current

as they are copies used to test the menus when the configuration file has been generated.

The build script (see below) copies the contents of ``www`` to the ``target`` directory when
it is run.


scripts
=======
Script used to create the JSON, timeline, and current version from the configuration files
for these files::

  www/cdap/json-versions.js
  www/cdap/version
  www/coopr/json-versions.js
  www/coopr/version
  www/tigon/json-versions.js
  www/tigon/version

Run ``build.sh`` to generate the JSON (for menu and timeline), and update the version
file, such as::

  $ ./build.sh cdap
  
To generate all JSONs and version files (intended for use by Bamboo build plans) use::

  $ ./build.sh all
  
To generate all JSONs and version files, and copy supporting files for manually checking results, use::

  $ ./build.sh test
  
You can then open index files (such as ``target/cdap/index.html`` and ``target/cdap/current/index.html``)
and check the generated timelines and drop-down version menus.
  
For usage::

  $ ./build.sh

The Python script (``builder.py``) is called by ``build.sh`` and actually generates the timeline and version files.

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
