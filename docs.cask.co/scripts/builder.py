#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright © 2015-2017 Cask Data, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the 'License"); you may not
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

# builder.py to create JSON file

# version 0.6

# JSON Creation (json-versions.js)
# Creates a JSON file with timeline and formatting information from the data in a 
# supplied configuration file.
#
# Writes out the current version to a file "version" and 
# the last development version to a file "development"


import os
import sys
from datetime import datetime
from optparse import OptionParser


def parse_options():
    """ Parses args options.
    """

    parser = OptionParser(
        usage="%prog config target",
        description='Builds a timeline and menu in Javascript format for a web page.')

    (options, args) = parser.parse_args()
    
    if len(args) < 2:
        parser.print_help()
        print "A 'config' and a 'target' must be supplied."
        sys.exit(1)
                
    return options, args, parser

def _build_timeline():
    """Takes a dictionary ('versions_data') from a global variable ('configuration')
    and creates a timeline in a JSON file.
    
    "versions_data" is a dictionary.
    
    "gcse" is a dictionary of Google Custom Search Engines, keyed by the version associated with the Search Engine.
    
    This modifies the "older", adding an extra element ('1') to flag the highest version(s) of the minor index.
    To be backward-compatible with older documentation sets, the "included-in-menu" field moves to index 4:
    
    ['2.7.1', '2.7.1', '2015-02-05', '1', '0']
    
    "versions_data":
    { 
      "gcse": {
        "4.1.0-SNAPSHOT": "002451258715120217843:v_9tcw7mwb0", 
        "4.0.0": "002451258715120217843:nkzqh6x__gy", 
        }, 
      "development": [
        ['3.1.0-SNAPSHOT', '3.1.0'], 
        ], 
      "current": ['3.0.1', '3.0.0', '2015-05-07'], 
      "older": [ 
        ['3.0.0', '3.0.0', '2015-05-05'], 
        ['2.8.0', '2.8.0', '2015-03-23'], 
        ['2.7.1', '2.7.1', '2015-02-05'], 
        ['2.6.3', '2.6.3', '2015-05-15'], 
        ['2.6.2', '2.6.2', '2015-03-23'], 
        ['2.6.1', '2.6.1', '2015-01-29'], 
        ['2.6.0', '2.6.0', '2015-01-10'], 
        ['2.5.2', '2.5.2', '2014-11-14'], 
        ['2.5.1', '2.5.1', '2014-10-15'], 
        ['2.5.0', '2.5.0', '2014-09-26'],
        ],
    },

    "timeline" is a list of lists. The first item of each inner list is the indentation of the inner list, with 0 being
    far-left, and increasing by 1. It is the same as the "older", but re-arranged into a hierarchy:

    'timeline': [
        ['0', '3.0.0', '2015-05-05', ' (43 days)'],
        ['0', '3.0.1', '2015-05-07', ' (2 days)'],
        ['0', '2.8.0', '2015-03-23', ' (46 days)'],
        ['0', '2.7.1', '2015-02-05', ' (26 days)'],
        ['0', '2.6.0', '2015-01-10', ' (106 days)'],
        ['1', '2.6.1', '2015-01-29', ' (19 days)'],
        ['1', '2.6.2', '2015-03-23', ' (53 days)'],
        ['0', '2.5.0', '2014-09-26', ''],
        ['1', '2.5.1', '2014-10-15', ' (19 days)'],
        ['1', '2.5.2', '2014-11-14', ' (30 days)'],
    ]
    
    """
    global configuration

    versions_data = configuration['versions_data']
    older = versions_data['older']
    rev_older = list(older)
    rev_older.insert(0, versions_data['current'])
    rev_older.reverse() # Now in lowest to highest versions
    data = []
    data_index = []
    
    # Make look-up dictionary
    data_lookup_dict = {}
    for release in rev_older:
        data_lookup_dict[release[0]] = release[2]
        
    # Find and flag highest version of minor index
    versions = []
    releases = len(older)
    for i in range(0, releases):
        style = ''
        version = older[i][0]
        version_major_minor = version[:version.rfind('.')]
        if i < (releases-1):
            next_version = older[i+1][0]
            next_version_major_minor = next_version[:next_version.rfind('.')]
            if version_major_minor not in versions and version_major_minor >= next_version_major_minor:
                versions.append(version_major_minor)
                style = '1'
        elif i == (releases-1):
            if version_major_minor not in versions:
                versions.append(version_major_minor)
                style = '1'
        if len(older[i]) > 3:
            included = older[i].pop()
            older[i].append(style)
            older[i].append(included)
        else:
            older[i].append(style)
        
    # Build Timeline
    previous_date = ''
    for release in rev_older:
        version = release[0]
        date = release[2]
        if not data:
            # First entry; always set indent to 0
            indent = '0'
            _add_to_start_of_timeline(data, data_index, indent, version, date)
        else:
            if version.endswith('0'):
                # is this a x.x.0 release?
                # yes: put at start of timeline
                previous_date = data_lookup_dict[data_index[0]]
                # Find the previous *.*.0 release
                for i in range(0, len(data_index)):
                    if data_index[i].endswith('0'):
                        previous_date = data_lookup_dict[data_index[i]]
                indent = '0'
                _add_to_start_of_timeline(data, data_index, indent, version, date)
            else:
                # no:
                # is there an x.x.0 release for this?
                version_major_minor = version[:version.rfind('.')]
                version_zero = version_major_minor + '.0'
                if version_zero in data_index:
                    # yes: put after last one in that series
                    index = 0
                    in_range = False
                    for i in range(0, len(data_index)):
                        entry = data_index[i]
                        entry_major_minor = entry[:entry.rfind('.')]
                        if entry_major_minor == version_major_minor:
                            index = i
                            in_range = True
                        if in_range and entry_major_minor != version_major_minor:
                            index += 1
                            break
                        if i == (len(data_index)-1):
                            index = i +1
                    indent = '1'
                    _insert_into_timeline(data, data_index, index, indent, version, date)
                else:
                    # no: add at top as the top level (indent=0)
                    index = 0
                    indent = '0'
                    _insert_into_timeline(data, data_index, index, indent, version, date)
                    
    # Calculate dates
    current_date = ''
    points = len(data)
    for i in range(0, points):
        # if d[0] = '0' doing outer level;
        level = data[i][0]
        date =  data[i][2]
        if level == '0':
            current_date = date
            # Find next '0' level:
            index = -1
            for k in range(i+1, points):
                if data[k][0] == '0':
                    index = k
                    break
            if index != -1:
                delta_string = diff_between_date_strings(date, data[index][2])
            else:
                delta_string = ''
        elif level == '1':
            # Dated from previous '0' level (current_date)
            delta_string = diff_between_date_strings(date, current_date)
            current_date = date
        data[i].append(delta_string)
    versions_data['older'] = older
    versions_data['timeline'] = data
    return versions_data

def _add_to_start_of_timeline(data, data_index, indent, version, date):
    _insert_into_timeline(data, data_index, 0, indent, version, date)

def _append_to_timeline(data, data_index, indent, version, date, style):
    _insert_into_timeline(data, data_index, len(data), indent, version, date)

def _insert_into_timeline(data, data_index, index, indent, version, date):
    data.insert(index, [indent, version, date])
    data_index.insert(index, version)

def diff_between_date_strings(date_a, date_b):
    date_format = '%Y-%m-%d'
    a = datetime.strptime(date_a, date_format)
    b = datetime.strptime(date_b, date_format)
    delta = b - a
    diff = abs(delta.days)
    if diff == 1:
        days = 'day'
    else:
        days = 'days'
    delta_string = " (%s %s)" % (diff, days)
    return delta_string

def get_current_version():
    global configuration
    current_version = None
    try:
        if 'versions_data' in configuration:
            versions_data = configuration['versions_data']
            if 'current' in versions_data and versions_data['current'][0]:
                current_version = "%s\n" % versions_data['current'][0]
    except Exception, e:
        pass
    return current_version

def get_development_version():
    global configuration
    development_version = None
    try:
        if 'versions_data' in configuration:
            versions_data = configuration['versions_data']
            if 'development' in versions_data and versions_data['development'][-1][0]:
                development_version = "%s\n" % versions_data['development'][-1][0]
    except Exception, e:
        pass
    return development_version

def print_current_version():
    print get_current_version()

def get_json_versions():
    return "versionscallback(%s);\n" % _build_timeline()

def print_json_versions():
    print get_json_versions()

def pretty_print_json_versions():
    data_dict = _build_timeline()
    for key in data_dict.keys():
        print "Key: %s" % key
        data = data_dict[key]
        for d in data:
            print d

def print_json_versions_file():
    global configuration
    head, tail = os.path.split(configuration['versions'])
    print tail

def read_configuration(config_file_path):
    """Reads a configuration file and generates a configuration dictionary from it."""
    global configuration
    print "Reading configuration file %s" % config_file_path
    configuration = {
      'versions':'',
      'versions_data':
        { 'development': [], 
          'current': [],
          'older': [],
          'gcse': { },
        },
    }
    sections = ['versions', 'development', 'current', 'older']
    section = None
    gcse_dict = dict()
    if os.path.isfile(config_file_path):
        with open(config_file_path,'r') as f:
            for line in f:
                line = line.strip()
                if line in sections:
                    section = line
                elif section:
                    if line.startswith('#') or not line:
                        continue
                    elif section == 'versions':
                        configuration[section] = line
                    else:
                        line_list, gcse = converted_line(line)
                        if section == 'current':
                             configuration['versions_data'][section] = line_list
                        else:
                             # In part of 'versions_data'
                             configuration['versions_data'][section].append(line_list)
                        if gcse and line_list[1]:
                            gcse_dict[line_list[1]] = gcse
                elif line.startswith('#') or not line:
                    section = None
        if gcse_dict:
            configuration['versions_data']['gcse'] = gcse_dict
    else:
        print "Did not find %s" % config_file_path
        configuration = None

def converted_line(line):
    line_list = line.replace(' ', '').split(',')
    if len(line_list) > 4:
        gcse = line_list[4]
    else:
        gcse = ''
    return line_list[0:4], gcse

def write_js_versions(target):
    files = []
    target_dir = os.path.dirname(target)
    if get_json_versions():
        files.append((target, get_json_versions()))
    version = get_current_version()
    if version:
        files.append((os.path.join(target_dir, 'version'), version))
    development = get_development_version()
    if development:
        files.append((os.path.join(target_dir, 'development'), development))
    if not os.path.exists(target_dir):
        try:
            os.makedirs(target_dir)
            print "Created %s" % target_dir
        except Exception, e:
            print "Could not write to %s" % target_dir
            raise e
    for file, get in files:
        with open(file,'w') as f:
            if not get:
                return 1
            f.write(get)
            print "Wrote to %s" % file
    
def main():
    """ Main program entry point.
    """
    global configuration
    options, args, parser = parse_options()
    read_configuration(args[0])
    if configuration:
        return_code = write_js_versions(args[1])
    else:
        return_code = 1
    sys.exit(return_code)
        
if __name__ == '__main__':
    main()
