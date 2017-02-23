/*
 * redirect-page.js
 * ----------------
 *
 * JavaScript for redirecting to an appropriate lower-level 404 page
 *
 * :copyright: © Copyright 2016 Cask Data, Inc.
 * :license: Apache License, Version 2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 *
 * version 0.2
 * 
 */

(function() {
  var products = new Array( TYPE_ARRAY );
  var origin = window.location.origin;     // "http://docs.cask.co"
  var pathname = window.location.pathname; // "/cdap/3.6.0/en/test.html"
  if (pathname[0] == '/') {
    pathname = pathname.substr(1);
  }
  var pathparts = pathname.split( '/' );
  if (products.indexOf(pathparts[0]) != -1 && pathparts.length > 1) {
    var re = /[0-9]\.[0-9]\.[0.9]/;
    if (pathparts[1].search(re) != -1 ) {
      var a = new Array(origin, pathparts[0], pathparts[1], 'en/404.html');
    } else {
      var a = new Array(origin, pathparts[0], '404.html');
    }
    var url = a.join('/');
    if (url && url != window.location.href) {
      window.location.replace(url);
    } else {
      console.log("redirect-page.js: reached the same location: " + url);
    }
  }
})();
