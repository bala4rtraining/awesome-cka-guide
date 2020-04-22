#!/usr/bin/env python

import sys, os, json
import requests
import argparse
from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar
from ansible.errors import AnsibleUndefinedVariable
from ansible.utils.shlex import shlex_split
from ansible.inventory.ini import InventoryParser


'''
 The script connects to the Consul agent reads the inventory information and writes
 the inventory information in JSON format as required by Ansible to STDOUT.
 The script will scan the path for datacenter and cluster name . 

 The usage example :- 

   /<installationdir>/indonesia/dc1/hosts_consul.py --list 

   The script will treat the 'dc1' as the datacenter and 'indonesia' as cluster 

   /<installationdir>/indonesia/hosts_consul.py --list

   In the above format the script will treat 'indonesia' as cluster .

   The above behavior is subject to change this is implimented as per the wiki mentioned below.

   https://visawiki.trusted.visa.com/display/OVN/Inventory+Management

   For the script to take the connection details of consul from the ovn_vars directory .
   
   By default the script assumes the consul is running at http://localhost:8500 if it cannot 
   find any configuration in respective ovn_vars of cluster or datacenter .
   
   example

   consulconnection: http://localhost:8500

'''



INVENTORY = 'inventory/'
DEFAULT_CONSUL_CONNECT = 'http://localhost:8500'
ANSIBLE_MIDDLEWARE = 'ansible_middleware'

try:
    import configparser
except ImportError:
    import ConfigParser as configparser

def msg(_type, text, exit=0):
    sys.stderr.write("%s: %s\n" % (_type, text))
    sys.exit(exit)

class DyInventoryParser(InventoryParser):
    def __init__(self):
        pass

class Consulconfig(dict):

    def __init__(self):
        #self.readconfig()
        self.load_ansible_vars()

    # keeping this code if in future if we change our approach to have separate config file
    def readconfig(self):
        config = configparser.SafeConfigParser()

        if os.path.isfile(os.path.dirname(os.path.realpath(__file__)) + '/consul_io.ini'):
            config.read(os.path.dirname(os.path.realpath(__file__)) + '/consul_io.ini')

        config_options = ['consulconnection']

        for option in config_options:
            value = None
            if config.has_option('consul', option):
                value = config.get('consul', option)
            setattr(self, option, value)

    # loads the respective  Ansible variables from the yaml files to python dictionary
    # for the cluster or data center.
    def load_ansible_vars(self):
        path = os.path.dirname(os.path.realpath(__file__))

        config_vars = {}

        # check if the hosts file is on middileware .
        if -1 != path.find(ANSIBLE_MIDDLEWARE):
            config_vars = self.load_ansible_vars_middleware()
        elif -1 != path.find('inventories'):
            config_vars = self.load_ansible_vars_inventories()

        config_options = ['consulconnection']

        for option in config_options:
            value = None
            if config_vars.has_key(option):
                value = config_vars.get(option)
            setattr(self, option, value)

    # loads the variables for Ansible Middileware
    def load_ansible_vars_middleware(self):
        path = os.path.dirname(os.path.realpath(__file__))

        toks = path.split(ANSIBLE_MIDDLEWARE)
        basepath = toks[0] + ANSIBLE_MIDDLEWARE + '/'

        temp = toks[1]
        toks = temp.split('/')

        # the temp  variable may be some thing like this
        # /inventories/mware/dc1
        # to check if we are in datacenter or cluster
        # we tokenize it on / and count the token list size
        # could not find a better way
        if len(toks) == 4:
            cluster_name = toks[2]
            datacenter_name = toks[3]
            is_datacenter = True
        elif len(toks) == 3:
            cluster_name = toks[2]
            is_datacenter = False

        dl = DataLoader()

        yaml_files_dir = basepath + 'vars' + '/'

        vars_template = {}

        try:
            self.load_vars_fromfile(yaml_files_dir, dl, vars_template)

            self.load_vars_fromfile(yaml_files_dir + cluster_name + '/', dl, vars_template)

            if is_datacenter == True:
                self.load_vars_fromfile(yaml_files_dir + cluster_name + '/' + datacenter_name + '/', dl, vars_template)

            return self.evaluate_vars(dl, vars_template)
        except Exception as e:
            msg('E', 'Could not load vars for middleware, Please check the path')

    # Loads the Ansible variables for inventories.
    def load_ansible_vars_inventories(self):
        path = os.path.dirname(os.path.realpath(__file__))
        toks = path.split('inventories')
        basepath = toks[0] + '/'

        temp = toks[1]
        toks = temp.split('/')

        if len(toks) == 3:
            cluster_name = toks[1]
            datacenter_name = toks[2]
            is_datacenter = True
        elif len(toks) == 2:
            cluster_name = toks[1]
            is_datacenter = False

        dl = DataLoader()

        yaml_files_dir = basepath + 'ovn_vars' + '/'

        vars_template = {}

        try:

            self.load_vars_fromfile(yaml_files_dir, dl, vars_template)

            self.load_vars_fromfile(yaml_files_dir + cluster_name + '/', dl, vars_template)

            if is_datacenter == True:
                self.load_vars_fromfile(yaml_files_dir + cluster_name + '/' + datacenter_name, dl, vars_template)

            return self.evaluate_vars(dl, vars_template)

        except Exception as e:
            msg('E', 'Could not load vars for inventories, Please check the path')

    # from files in a  directory load the yaml files to dictionary.
    def load_vars_fromfile(self, path_dir, dl, vars_template):
        var_files = [
            os.path.join(path_dir, file_name)
            for file_name in os.listdir(path_dir)
        ]

        for var_file in var_files:
            if var_file.endswith('.yml'):
                temp = dl.load_from_file(var_file)
                if temp is not None:
                    vars_template.update(temp)




    # Do the template substitution of the variables.
    def evaluate_vars(self, dl, vars_template):
        templar = Templar(loader=dl)
        result_vars = dict()

        for var_name, value in vars_template.items():
            try:
                templated_value = templar.template(value)
                result_vars[var_name] = templated_value
                templar.set_available_variables(result_vars.copy())
            except AnsibleUndefinedVariable:
                pass

        return result_vars


class Consuldynamicinventory(object):

    def __init__(self):
        self.config = Consulconfig()

    def sendget(self, urlconsul):
        try:
            response = requests.get(urlconsul)
            if response.status_code == requests.codes.ok:
                if len(response.text) == 0:
                    return False, {}
                else:
                    return True, response.json()
            else:
                return False,{}
        except requests.exceptions.RequestException as e:
            msg('E', 'Exception %s trying to connect to %s '%(e.message,urlconsul))

    def parse_host_vars(self, host_names):
        host_list = []
        vars_json = {}
        mip = DyInventoryParser()
        for item in host_names:
            try:
                tokens = shlex_split(item, comments=True)
            except ValueError as e:
                msg('E', "Error parsing host definition '%s': %s" % (line, e))

            (hosts, port) = mip._expand_hostpattern(tokens[0])
            tok = []
            tok = tokens[1:]

            variables = {}

            for t in tok:
                if '=' not in t:
                    msg(
                        'E',
                        "Expected key=value host variable assignment, "
                        "got: %s" % (t))

                (k, v) = t.split('=', 1)
                variables[k] = mip._parse_value(v)

            for host in hosts:
                host_list.append(host)

                for key, val in variables.iteritems():
                    if host not in vars_json:
                        vars_json[host] = {}
                    vars_json[host][key] = val

        return host_list,vars_json

    def readFromConsul(self, consulconnect, cluster , datacenter ,out_data):

        response = requests.get( consulconnect + INVENTORY + '/' + cluster + '/' + datacenter + '/groups/' + '?keys&seperator=/')

        CHILDREN_STR = 'children'
        GROUPS_STR   = 'groups'
        HOSTS_STR    = 'hosts'
        VARS_STR     = 'vars'
        RAW_STR      = '?raw'
        KEYS_STR     = '?keys'
        META_STR     = '_meta'
        HOSTVARS_STR = 'hostvars'

        data = response.json()

        #parse the groups
        for group in data:
            toks = group.split('/')
            group_name = toks[len(toks)-2]
            if group_name == GROUPS_STR:
                continue

            response = requests.get( consulconnect+ group + KEYS_STR)
            data_groups = response.json()

            for key in data_groups:

                if key.endswith(CHILDREN_STR):
                    response = requests.get(consulconnect + key + RAW_STR)
                    if group_name not in out_data:
                        out_data[group_name] = {}
                        out_data[group_name][CHILDREN_STR] = response.json()
                    else:
                        out_data[group_name][CHILDREN_STR] = out_data[group_name][CHILDREN_STR] + response.json()

                elif key.endswith(HOSTS_STR):
                    response = requests.get(consulconnect+key+RAW_STR)
                    if group_name not in out_data:
                        out_data[group_name] = {}
                        host_list, vars_json = self.parse_host_vars(response.json())
                        out_data[group_name][HOSTS_STR] = host_list
                        #adding host vars
                        if len(vars_json) > 0:
                            out_data[META_STR][HOSTVARS_STR].update(vars_json)
                    else:
                        host_list, vars_json = self.parse_host_vars(response.json())
                        out_data[group_name][HOSTS_STR] = out_data[group_name][HOSTS_STR] + host_list
                        #adding host vars
                        if len(vars_json) > 0:
                           out_data[META_STR][HOSTVARS_STR].update(vars_json)

                elif key.endswith(VARS_STR):
                    response = requests.get(consulconnect + key + RAW_STR)
                    if group_name not in out_data:
                        out_data[group_name] = {}
                        out_data[group_name][VARS_STR] = response.json()
                    else:
                        if 'vars' not in out_data[group_name]:
                            out_data[group_name][VARS_STR] = {}
                            out_data[group_name][VARS_STR] = response.json()
                        else:
                            out_data[group_name][VARS_STR].update(response.json())

    def read_inventory(self):

        if self.config.consulconnection == None:
            consulconnect = DEFAULT_CONSUL_CONNECT + '/v1/kv/'
        else:
            consulconnect = self.config.consulconnection + '/v1/kv/'

        #cluster or datacenter ...
        path = os.path.dirname(os.path.realpath(__file__))
        toks = path.split('/')
        #cluster or DC
        path = toks[len(toks) - 1]
        #can be only cluster if path is DC
        path2 = toks[len(toks) - 2]

        clustername = ''
        datacentername = ''
        iscluster = False
        isdatacenter = False

        #check for cluster
        ret, data = self.sendget(consulconnect + INVENTORY + '?keys&seperator=/')
        if ret == True:
            for key in data :
                if key == INVENTORY + path + '/':
                    iscluster = True
                    clustername = path
                    break

        #if we cannot find a cluster we should look for datacenter
        if iscluster == False:
            ret, data = self.sendget(consulconnect + INVENTORY + path2 + '/?keys&seperator=/')
            if ret == True:
                for key in data:
                    if key == INVENTORY + path2 + '/' + path + '/':
                        isdatacenter = True
                        clustername    = path2
                        datacentername = path
                        break


        #if we cannot find both datacenter or cluster lets exit
        if iscluster == False and isdatacenter == False:
            msg( 'E','Cannot find cluster %s or datacenter %s in inventory '%(path2,path))


        out_data = {}
        #lets find the data centers
        if iscluster == True:
            #the cluster and DC information
            out_data = {'all': {'vars': {'CLUSTER': clustername}}, "_meta": {"hostvars": {}}}
            ret, data = self.sendget(consulconnect + INVENTORY + clustername + '/?keys&seperator=/')
            if ret == True:
                for key in data:
                    toks = key.split('/')
                    datacentername = toks[len(toks) - 2]
                    self.readFromConsul(consulconnect, clustername, datacentername, out_data)
        else:
            #the cluster and Dc information ..
            out_data = {'all': {'vars': {'CLUSTER': clustername,'DATACENTER':datacentername}},"_meta": { "hostvars": {}}}
            self.readFromConsul(consulconnect, clustername, datacentername, out_data)

        print json.dumps(out_data, sort_keys=True, indent=2)

if __name__ == '__main__':

    # Read command line options
    parser = argparse.ArgumentParser(
        description=(
            'Dynamic inventory script for Consul'))

    parser.add_argument(
        '--list',
        action='store_true',
        help='List all groups and hosts')

    args = parser.parse_args()
    #actually we take only one argument other args in future
    ## we can add more funcionality

    dyninv = Consuldynamicinventory()
    dyninv.read_inventory()