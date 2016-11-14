/*
 * build-links-from-json-versions.js
 * ---------------------------------
 * version 3
 *
 * JavaScript for building links from the json-versions.js file
 *
 * :copyright: © Copyright 2015 Cask Data, Inc.
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
 */

(function() {
  var fixedDate = (function(date){
    var revisedDate = new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
    return revisedDate.toLocaleDateString();
  });
  var writelink = (function(dir, style, date){
    var styleStart = '';
    var styleEnd = '';
    if (style) {
      styleStart = '<' + style + '>';
      styleEnd = '</' + style + '>';
    }
    document.write('<li>' + styleStart + '<a class="reference external" href="' + dir + '/en/index.html" ' + style + '>Version ' + dir + '</a> ');
    if (date) { 
      document.write('&nbsp;&nbsp;<em>' + fixedDate(date) + '</em>'); 
    }
    document.write(styleEnd + '</li>');
  });
  var buildtimeline = (function(timeline){
    var i;
    var indentPreText = '';
    var indentPostText = '';
    document.write('<ul class="simple"><li><b>Timeline</b> <i>(Days are from the previous release of a version in the same category)</i></li><ul>');
    for (i in timeline) {
      if (parseInt(timeline[i][0]) === 1) {
        indentPreText = '<ul>';
        indentPostText = '</ul>';
      } else {
        indentPreText = '';
        indentPostText = '';
      }
      date = new Date(timeline[i][2]);
      document.write(indentPreText + '<li>' + timeline[i][1] + '&nbsp;&nbsp;<i>' + fixedDate(date) + timeline[i][3] + '</i></li>' + indentPostText);
    }
    document.write('</ul></ul>');
  });
  window.versionscallback = (function(data){
    var ess = "s";
    var i;
    var date;
    var datedreleases = [];
    var style;
    if (data) {
      document.write('<div>');
    }
    if (data.development && data.development.length > 0) {
      ess = (data.development.length == 1) ? "" : "s" ;
      document.write('<ul class="simple"><li><a class="reference external" href="develop/en/index.html" style="font-weight:bold;">Development Release' + ess +'</a></li><ul>');          
      for (i in data.development) {
        writelink(data.development[i][0]);
      }
      document.write('</ul></ul>');
    }
    if (data.current && data.current.length > 0) {
      document.write('<ul class="simple"><li><a class="reference external" href="current/en/index.html" style="font-weight:bold;">Current Release</a></li><ul>');          
      if (data.current.length > 2) {
        date = new Date(data.current[2]);
        datedreleases[0] = {"release": data.current[0], "date": date};
      } else {
        date = "";
      }
      writelink(data.current[0], 'style="font-weight:bold;"', date);      
      document.write('</ul></ul>');
    }
    if (data.older && data.older.length > 0) {
      ess = (data.older.length == 1) ? "" : "s" ;      
      document.write('<ul class="simple"><li><b>Older Release' + ess +'</b></li><ul>');
      for (i in data.older) {
        if (data.older[i].length >2) {
          date = new Date(data.older[i][2]);
          datedreleases.push({ "release": data.older[i][0], "date": date });
        } else {
          date = "";
        }
        if (parseInt(data.older[i][3]) === 1) {
          style = 'b';
        } else {
          style = '';
        }
        writelink(data.older[i][0], style, date);
      }
      document.write('</ul></ul>');
    }
    if (data.timeline) {
      buildtimeline(data.timeline);
    }
    if (data) {
      document.write('</div>');
    }
  });
})();
