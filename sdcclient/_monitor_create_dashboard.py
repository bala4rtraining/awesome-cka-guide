import json
import copy
import requests
import re

from sdcclient._common import _SdcCommon

try:
    basestring
except NameError:
    basestring = str
	
def create_dashboard_from_template(self, dashboard_name, template, scope, shared=False, public=False):
        if scope is not None:
            if isinstance(scope, basestring) == False:
                return [False, 'Invalid scope format: Expected a string']

        #
        # Clean up the dashboard we retireved so it's ready to be pushed
        #
        template['id'] = None
        template['version'] = None
        template['schema'] = 2
        template['name'] = dashboard_name
        template['shared'] = shared
        template['public'] = public
        template['publicToken'] = None

        # default dashboards don't have eventsOverlaySettings property
        # make sure to add the default set if the template doesn't include it
        if 'eventsOverlaySettings' not in template or not template['eventsOverlaySettings']:
            template['eventsOverlaySettings'] = {
                'filterNotificationsUserInputFilter': ''
            }

        # set dashboard scope to the specific parameter
        scopeExpression = self.convert_scope_string_to_expression(scope)
        if scopeExpression[0] == False:
            return scopeExpression
        if scopeExpression[1]:
            template['scopeExpressionList'] = map(lambda ex: {'operand': ex['operand'], 'operator': ex['operator'], 'value': ex['value'], 'displayName': '', 'variable': False}, scopeExpression[1])
	else:
            template['scopeExpressionList'] = None

        # NOTE: Individual panels might override the dashboard scope, the override will NOT be reset
        if 'widgets' in template and template['widgets'] is not None:
            for chart in template['widgets']:
                if 'overrideScope' not in chart:
                    chart['overrideScope'] = False

                if chart['overrideScope'] == False:
                    # patch frontend bug to hide scope override warning even when it's not really overridden
                    chart['scope'] = scope

                if chart['showAs'] != 'map':
                    # if chart scope is equal to dashboard scope, set it as non override
                    chart_scope = chart['scope'] if 'scope' in chart else None
                    chart['overrideScope'] = chart_scope != scope
                else:
                    # topology panels must override the scope
                    chart['overrideScope'] = True

        #
        # Create the new dashboard
        #
        res = requests.post(self.url + self._dashboards_api_endpoint, headers=self.hdrs, data=json.dumps({'dashboard': template}), verify=self.ssl_verify)

        return self._request_result(res)
