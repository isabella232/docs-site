/*
 * replace-table-of-contents.js
 * ----------------------------
 *
 * JavaScript for replacing the table of contents with another one 
 *
 * :copyright: © Copyright 2015-2017 Cask Data, Inc.
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
  $("#loadedCurrentReleaseMenu").load("current/en/index.html [aria-label='manuals links'],[aria-label='globaltoc links']", 
    function( response, status, xhr ) {
      if (status != 'success') {
        return;
      }
      $("#loadedCurrentReleaseMenu").find("li").each(function() {
          if (this.textContent == 'Search') {
              var parentUL = this.parentNode;
              parentUL.removeChild(this);
          } else {
              $(this).find("a").each(function() {
                  this.href = "current/en/" + $(this).attr("href");
              });
          }
      });
      $("#loadedCurrentReleaseMenu").find("h3").each(function() {
          this.innerHTML = this.innerHTML + " (Current&nbsp;Release)";
          $(this).find("a").each(function() {
              this.href = "current/en/" + $(this).attr("href");
          });
      });
  });
})();
