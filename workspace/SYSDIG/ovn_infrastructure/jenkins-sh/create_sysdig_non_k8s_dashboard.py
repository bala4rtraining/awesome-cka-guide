#!/usr/bin/env python
#
# Script for creating emtpy dashboard, adding panels to the dashboard
# For Non K8s 

import getopt
import os
import sys
import json
import copy
import requests
import re
import csv
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

# sdclient class

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

##### create an empty dashboard

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
        # dashboard configuration

        dashboard_configuration = {
            'name': name,
            'schema': 2,
            'widgets': [],
            'eventsOverlaySettings': {
                'filterNotificationsUserInputFilter': ''
            }
        }

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

## Adds a panel to the dashboard

    def add_dashboard_panel(self, dashboard, name, panel_type, metrics, scope=None, sort_direction='desc', limit=None, layout=None):
        """**Description**
            Adds a panel to the dashboard. A panel can be a time series, or a top chart (i.e. bar chart), or a number panel.
        **Arguments**
            - **dashboard**: dashboard to edit
            - **name**: name of the new panel
            - **panel_type**: type of the new panel. Valid values are: ``timeSeries``, ``top``, ``number``
            - **metrics**:  a list of dictionaries, specifying the metrics to show in the panel, and optionally, if there is only one metric, a grouping key to segment that metric by. A metric is any of the entries that can be found in the *Metrics* section of the Explore page in Sysdig Monitor. Metric entries require an *aggregations* section specifying how to aggregate the metric across time and groups of containers/hosts. A grouping key is any of the entries that can be found in the *Show* or *Segment By* sections of the Explore page in Sysdig Monitor. Refer to the examples section below for ready to use code snippets. Note, certain panels allow certain combinations of metrics and grouping keys:
                - ``timeSeries``: 1 or more metrics OR 1 metric + 1 grouping key
                - ``top``: 1 or more metrics OR 1 metric + 1 grouping key
                - ``number``: 1 metric only
            - **scope**: filter to apply to the panel; must be based on metadata available in Sysdig Monitor; Example: *kubernetes.namespace.name='production' and container.image='nginx'*.
            - **sort_direction**: Data sorting; The parameter is optional and it's a string identifying the sorting direction (it can be ``desc`` or ``asc``)
            - **limit**: This parameter sets the limit on the number of lines/bars shown in a ``timeSeries`` or ``top`` panel. In the case of more entities being available than the limit, the top entities according to the sort will be shown. The default value is 10 for ``top`` panels (for ``timeSeries`` the default is defined by Sysdig Monitor itself). Note that increasing the limit above 10 is not officially supported and may cause performance and rendering issues
            - **layout**: Size and position of the panel. The dashboard layout is defined by a grid of 12 columns, each row height is equal to the column height. For example, say you want to show 2 panels at the top: one panel might be 6 x 3 (half the width, 3 rows height) located in row 1 and column 1 (top-left corner of the viewport), the second panel might be 6 x 3 located in row 1 and position 7. The location is specified by a dictionary of ``row`` (row position), ``col`` (column position), ``size_x`` (width), ``size_y`` (height).
        **Success Return Value**
            A dictionary showing the details of the edited dashboard.
        **Example**
            `examples/dashboard.py <https://github.com/draios/python-sdc-client/blob/master/examples/dashboard.py>`_
        """

   # Panel configuration

        panel_configuration = {
            'name': name,
            'showAs': None,
            'metrics': [],
            'gridConfiguration': {
                'col': 1,
                'row': 1,
                'size_x': 12,
                'size_y': 6
            },
            'customDisplayOptions': {}
        }

   # panel type

        if panel_type == 'timeSeries':
            #
            # In case of a time series, the current dashboard implementation
            # requires the timestamp to be explicitly specified as "key".
            # However, this function uses the same abstraction of the data API
            # that doesn't require to specify a timestamp key (you only need to
            # specify time window and sampling)
            #
            metrics = copy.copy(metrics)
            metrics.insert(0, {'id': 'timestamp'})

        #
        # Convert list of metrics to format used by Sysdig Monitor
        #
        property_names = {}
        k_count = 0
        v_count = 0
        for i, metric in enumerate(metrics):
            property_name = 'v' if 'aggregations' in metric else 'k'

            if property_name == 'k':
                i = k_count
                k_count += 1
            else:
                i = v_count
                v_count += 1
            property_names[metric['id']] = property_name + str(i)

            panel_configuration['metrics'].append({
                'id': metric['id'],
                'timeAggregation': metric['aggregations']['time'] if 'aggregations' in metric else None,
                'groupAggregation': metric['aggregations']['group'] if 'aggregations' in metric else None,
                'propertyName': property_name + str(i)
            })

        panel_configuration['scope'] = scope
        # if chart scope is equal to dashboard scope, set it as non override
        panel_configuration['overrideScope'] = ('scope' in dashboard and dashboard['scope'] != scope) or ('scope' not in dashboard and scope != None)

        if 'custom_display_options' not in panel_configuration:
            panel_configuration['custom_display_options'] = {
                'valueLimit': {
                    'count': 10,
                    'direction': 'desc'
                },
                'histogram': {
                    'numberOfBuckets': 10
                },
                'yAxisScale': 'linear',
                'yAxisLeftDomain': {
                    'from': 0,
                    'to': None
                },
                'yAxisRightDomain': {
                    'from': 0,
                    'to': None
                },
                'xAxis': {
                    'from': 0,
                    'to': None
                }
            }
        #
        # Configure panel type
        #
        if panel_type == 'timeSeries':
            panel_configuration['showAs'] = 'timeSeries'

            if limit != None:
                panel_configuration['custom_display_options']['valueLimit'] = {
                    'count': limit,
                    'direction': 'desc'
                }

        elif panel_type == 'number':
            panel_configuration['showAs'] = 'summary'
        elif panel_type == 'top':
            panel_configuration['showAs'] = 'top'

            if limit != None:
                panel_configuration['custom_display_options']['valueLimit'] = {
                    'count': limit,
                    'direction': sort_direction
                }

        #
        # Configure layout
        #
        if layout != None:
            panel_configuration['gridConfiguration'] = layout

        #
        # Clone existing dashboard...
        #
        dashboard_configuration = copy.deepcopy(dashboard)

        #
        # ... and add the new panel
        #
        dashboard_configuration['widgets'].append(panel_configuration)

        #
        # Update dashboard
        #
        res = requests.put(self.url + self._dashboards_api_endpoint + '/' + str(dashboard['id']), headers=self.hdrs, data=json.dumps({'dashboard': dashboard_configuration}),
                           verify=self.ssl_verify)
        return self._request_result(res)

######## End of the Class


# method starts here

sdc_token = args[0]
sdclient = SdMonitorClient()

# Name for the dashboard to create

dashboardName = ""
kubernetes_cluster_name = ""
kubernetes_namespace_name= ""
kubernetes_deployment_name= ""

for opt, arg in opts:
    if opt in ("-d", "--dashboard"):
        dashboardName = arg

if len(args) != 1:
    usage()

ok, res = sdclient.create_dashboard(dashboardName)

#
# Check the result
#
if ok:
    print('Dashboard %d created successfully' % res['dashboard']['id'])
    dashboard_configuration = res['dashboard']
else:
    print(res)
    sys.exit(1)

scope = 'proc.name = "cassandra"' 
layout_incr = 6
row_new = -5


with open('jenkins-sh/sysdig_metrics_csv/cassandra_metrics.csv') as csvfile:
    readCSV = csv.reader(csvfile, delimiter=',')
    for row in readCSV:
        print(row)
	panel_name = row[0]
	panel_type = row[1]
	metrics = [
        	{'id': row[2], 'aggregations': {'time': 'avg', 'group': 'avg'}}
	]

        row_new = layout_incr + row_new
        layout = {'col': 1, 'row': row_new, 'size_x': 12, 'size_y': 6}
	ok, res = sdclient.add_dashboard_panel(dashboard_configuration, panel_name, panel_type, metrics, layout=layout, scope=scope)

	print(scope)

	# Check the result
	if ok:
	   print('Panel added successfully')
    	   dashboard_configuration = res['dashboard']
	else:
    	   print(res)
    	   sys.exit(1)
