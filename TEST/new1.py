#!/usr/bin/env python
#
# This example shows two easy ways to create a dasboard: using a view as a
# templeate, and copying another dashboard.
# In both cases, a filter is used to define what entities the new dashboard
# will monitor.
#

import getopt
import os
import sys
import json
import copy
import requests
import re
sys.path.insert(0, os.path.join(os.path.dirname(os.path.realpath(sys.argv[0])), '..'))

#
# Parse arguments
#
def usage():
    print('usage: %s [-d|--dashboard <name>] <sysdig-token>' % sys.argv[0])
    print('-d|--dashboard: Set name of dashboard to create')
    print('You can find your token at https://app.sysdigcloud.com/#/settings/user')
    sys.exit(1)


try:
    opts, args = getopt.getopt(sys.argv[1:], "d:", ["dashboard="])
except getopt.GetoptError:
    usage()

sdc_token = ""

class SdMonitorClient():

    def __get_headers(self, custom_headers):
        headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + sdc_token,
            'X-Sysdig-Product': 'SDC'
        }
        if custom_headers:
            headers.update(custom_headers)
        return headers

    def __init__(self, token="", sdc_url='https://app.sysdigcloud.com', ssl_verify=True, custom_headers=None):
        self.token = os.environ.get("SDC_TOKEN", token)
        self.hdrs = self.__get_headers(custom_headers)
        self.url = os.environ.get("SDC_URL", sdc_url)
        self.product = "SDC"
        self.ssl_verify = os.environ.get("SDC_SSL_VERIFY", None)
        self._dashboards_api_version = 'v2'
        self._dashboards_api_endpoint = '/api/{}/dashboards'.format(self._dashboards_api_version)
        self._default_dashboards_api_endpoint = '/api/{}/defaultDashboards'.format(self._dashboards_api_version)
        if self.ssl_verify == None:
            self.ssl_verify = ssl_verify
        else:
            self.ssl_verify = self.ssl_verify.lower() == 'true'


    def _checkResponse(self, res):
        if res.status_code >= 300:
            errorcode = res.status_code
            self.lasterr = None

            try:
                j = res.json()
            except Exception:
                self.lasterr = 'status code ' + str(errorcode)
                return False

            if 'errors' in j:
                error_msgs = []
                for error in j['errors']:
                    error_msg = []
                    if 'message' in error:
                        error_msg.append(error['message'])

                    if 'reason' in error:
                        error_msg.append(error['reason'])

                    error_msgs.append(': '.join(error_msg))

                self.lasterr = '\n'.join(error_msgs)
            elif 'message' in j:
                self.lasterr = j['message']
            else:
                self.lasterr = 'status code ' + str(errorcode)
            return False
        return True

##### create dashboard

    def create_dashboard(self, name):
        '''
        **Description**
            Creates an empty dashboard. You can then add panels by using ``add_dashboard_panel``.
        **Arguments**
            - **name**: the name of the dashboard that will be created.
        **Success Return Value**
            A dictionary showing the details of the new dashboard.
        **Example**
            `examples/dashboard.py <https://github.com/draios/python-sdc-client/blob/master/examples/dashboard.py>`_
        '''
        dashboard_configuration = {
            'name': name,
            'schema': 2,
            'widgets': [],
            'eventsOverlaySettings': {
                'filterNotificationsUserInputFilter': ''
            }
        }

        #
        # Create the new dashboard
        #
        res = requests.post(self.url + self._dashboards_api_endpoint, headers=self.hdrs, data=json.dumps({'dashboard': dashboard_configuration}),
                            verify=self.ssl_verify)
        return self._request_result(res)
    def _request_result(self, res):
        if not self._checkResponse(res):
            return False, self.lasterr

        return True, res.json()

    def convert_scope_string_to_expression(self, scope):
        '''**Description**
            Internal function to convert a filter string to a filter object to be used with dashboards.
        '''
        #
        # NOTE: The supported grammar is not perfectly aligned with the grammar supported by the Sysdig backend.
        # Proper grammar implementation will happen soon.
        # For practical purposes, the parsing will have equivalent results.
        #

        if scope is None or not scope:
            return [True, []]

        expressions = []
        string_expressions = scope.strip(' \t\n\r').split(' and ')
        expression_re = re.compile('^(?P<not>not )?(?P<operand>[^ ]+) (?P<operator>=|!=|in|contains|starts with) (?P<value>(:?"[^"]+"|\'[^\']+\'|\(.+\)|.+))$')

        for string_expression in string_expressions:
            matches = expression_re.match(string_expression)

            if matches is None:
                return [False, 'invalid scope format']

            is_not_operator = matches.group('not') is not None

            if matches.group('operator') == 'in':
                list_value = matches.group('value').strip(' ()')
                value_matches = re.findall('(:?\'[^\',]+\')|(:?"[^",]+")|(:?[,]+)', list_value)

                if len(value_matches) == 0:
                    return [False, 'invalid scope value list format']
                value_matches = map(lambda v: v[0] if v[0] else v[1], value_matches)
                values = map(lambda v: v.strip(' "\''), value_matches)
            else:
                values = [matches.group('value').strip('"\'')]

            operator_parse_dict = {
                'in': 'in' if not is_not_operator else 'notIn',
                '=': 'equals' if not is_not_operator else 'notEquals',
                '!=': 'notEquals' if not is_not_operator else 'equals',
                'contains': 'contains' if not is_not_operator else 'notContains',
                'starts with': 'startsWith'
            }

            operator = operator_parse_dict.get(matches.group('operator'), None)
            if operator is None:
                return [False, 'invalid scope operator']

            expressions.append({
                'operand': matches.group('operand'),
                'operator': operator,
                'value': values
            })

        return [True, expressions]

########

sdc_token = args[0]
sdclient = SdMonitorClient()

# Name for the dashboard to create
dashboardName = "Overview by Process"
for opt, arg in opts:
    if opt in ("-d", "--dashboard"):
        dashboardName = arg

if len(args) != 1:
    usage()

#
# Make a Copy the just created dasboard, this time applying it to cassandra in
# the dev namespace
#
# Name of the dashboard to copy
dashboardCopy = "Copy of {}".format(dashboardName)
# Filter to apply to the new dashboard. Same as above.
dashboardFilter = 'proc.name != "cassandra"'

print('Creating dashboard from dashboard')
#ok, res = sdclient.create_dashboard_from_dashboard(dashboardCopy, dashboardName, dashboardFilter)
#ok, res = sdclient.create_dashboard(name)
ok, res = sdclient.create_dashboard(dashboardName)

#
# Check the result
#
if ok:
    print('Dashboard copied successfully')
else:
    print(res)
    sys.exit(1)
