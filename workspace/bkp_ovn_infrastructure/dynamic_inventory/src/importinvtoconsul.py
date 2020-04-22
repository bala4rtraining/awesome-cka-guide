#!/usr/bin/env python

from ansible.utils.shlex import shlex_split
from ansible.inventory.ini import InventoryParser

import argparse
import json
import os
import sys
import yaml
import requests

'''
 The script imports the inventory data from the INI inventory files to Consul
 It takes two arguments 
        --consul <consul connection string>
        --clusterpath <path to the cluster>
        --debug prints the debug information of the import activity.
 
 usage example 
 
   importinvtoconsul.py --consul localhost:8500 --clusterpath /Users/skaripar/project/ovn_infrastructure/inventories/indonesia 
   importinvtoconsul.py --consul localhost:8500 --clusterpath /Users/skaripar/project/ovn_infrastructure/inventories/dev

'''


class DyInventoryParser(InventoryParser):
    def __init__(self):
        pass

def msg(_type, text, exit=0):
    sys.stderr.write("%s: %s\n" % (_type, text))
    sys.exit(exit)

def getsubdirs( path):
    dirlist = []
    for d in os.listdir( path):
        if os.path.isdir(os.path.join(path,d)):
            dirlist.append(os.path.join(path,d))
    return dirlist

def isDataCenter(path):
    for d in os.listdir(path):
        if d == 'hosts':
            return True
    return False


def main():

    # Read command line options
    parser = argparse.ArgumentParser(
        description=(
            'Script that reads inventory file in the INI '
            'format and seeds the Consul'))


    parser.add_argument(
        '--consul',required=True,
        help='Connect string of Consul')

    parser.add_argument(
        '--clusterpath',required=True,
        help='Path of the inventory files of cluster')

    parser.add_argument('--debug',action='store_true',
                        help='debug information')

    args = parser.parse_args()

    sub_dirs = getsubdirs(args.clusterpath)

    for dir in sub_dirs:
        if isDataCenter(dir):
            #find out the cluster name & datacenter name
            tokens = dir.split('/')
            cluster_name = tokens[len(tokens)-2]
            datacenter_name = tokens[len(tokens)-1]
            print "creating inventory for cluster " + cluster_name + " datacenter "+ datacenter_name
            create_inventory(args.consul, dir, cluster_name, datacenter_name, args.debug)
        else:
            print "skipping directory " + dir


def create_inventory(consul, filePath, cluster_name, datacenter_name, debug):

    data = {}

    ALL   = 'all'
    VARS  = 'vars'
    HOSTS = 'hosts'
    CHILDREN = 'children'

    data[ALL] = {}

    data[ALL][VARS] = {}

    group_vars = os.path.join(filePath, "group_vars/all.yml")

    consulconnect = 'http://'+consul+'/v1/kv/inventory/'+cluster_name+'/'+datacenter_name+'/'+'groups/'

    response = requests.put(consulconnect)

    if response.status_code != requests.codes.ok and response.text.find('false'):
        msg('E', 'Cannot create group ...')

    try:
        f = open(group_vars)
        yml = yaml.load(f)
        data[ALL][VARS] = yml
        f.close()
    except Exception as e:
        pass

    data['_meta'] = { 'hostvars': {} }

    if os.path.isdir(filePath):
        for root, dirlist, filelist in os.walk(filePath):
            for f in filelist:
                filename = os.path.join(root,f)

                if f != 'hosts':
                    continue

                try:
                    f = open(filename)
                except Exception as e:
                    msg('E', 'Cannot open inventory file %s. %s' % (filename, str(e)))

                group = None
                state = None
                mip = DyInventoryParser()

                children_json = []
                hosts_json = []
                vars_json = {}

                # Walk through the file and build the data structure
                for line in f:
                    line = line.strip()

                    # Skip comments and empty lines
                    if line.startswith('#') or line.startswith(';') or len(line) == 0:
                        continue

                    if line.startswith('['):

                        # we are either done with hosts or children ..lets check the state
                        if state == HOSTS:
                            requests.put(consulconnect+group+'/'+'hosts',json.dumps(hosts_json) )
                        elif state == CHILDREN:
                            requests.put(consulconnect+group+'/'+'children', json.dumps(children_json))
                        elif state == VARS:
                            requests.put(consulconnect+group+'/'+'vars', json.dumps(vars_json))

                        # Parse group
                        section = line[1:-1]

                        if ':' in line:
                            group, state = line[1:-1].split(':')
                            # children_json = {state: []}
                            children_json = []
                            vars_json = {}
                        else:
                            group = section
                            state = HOSTS
                            # hosts_json = {state: []}
                            hosts_json = []

                        if group not in data:
                            requests.put(consulconnect+'/'+group+'/')
                            data[group] = {}

                        if state not in data[group]:
                            requests.put(consulconnect + '/' + group + '/' + state)
                            if state == VARS:
                                data[group][state] = {}
                            else:
                                data[group][state] = []
                    else:
                        # Parse hosts or group members/vars
                        try:
                            tokens = shlex_split(line, comments=True)
                        except ValueError as e:
                            msg('E', "Error parsing host definition '%s': %s" % (line, e))

                        (hostnames, port) = mip._expand_hostpattern(tokens[0])

                        # Create 'all' group if no group was defined yet
                        if group is None:
                            group = 'all'
                            state = HOSTS
                            data['all'] = {
                                'hosts': []
                            }

                        tok = []

                        if state == HOSTS:
                            tok = tokens[1:]
                        elif state == VARS:
                            tok = tokens

                        variables = {}

                        for t in tok:
                            if '=' not in t:
                                msg(
                                    'E',
                                    "Expected key=value host variable assignment, "
                                    "got: %s" % (t))

                            (k, v) = t.split('=', 1)
                            variables[k] = mip._parse_value(v)

                        if state == VARS:
                            for key, val in variables.iteritems():
                                data[group][state][key] = val
                                vars_json[key]=val
                        else:
                            for host in hostnames:
                                data[group][state].append(host)

                                if state == HOSTS and len(variables):

                                    if host not in data['_meta']['hostvars']:
                                        data['_meta']['hostvars'][host] = {}
                                    for key, val in variables.iteritems():
                                        data['_meta']['hostvars'][host][key] = val

                                if state == HOSTS:
                                    host = ''
                                    for item in tokens:
                                        host = host + ' ' + item
                                    hosts_json.append(host.strip(' '))
                                else:
                                    children_json.append(host)

                if state == HOSTS:
                    requests.put(consulconnect + group + '/' + 'hosts', json.dumps(hosts_json))
                elif state == CHILDREN:
                    requests.put(consulconnect + group + '/' + 'children', json.dumps(children_json))
                elif state == VARS:
                    requests.put(consulconnect + group + '/' + 'vars', json.dumps(vars_json))

                try:
                    f.close()
                except IOError as e:
                    msg('E', 'Cannot close inventory file %s. %s' % (filename, str(e)))

    if debug:
        print(json.dumps(data, sort_keys=True, indent=2))
    print ("success")

if __name__ == '__main__':
    main()