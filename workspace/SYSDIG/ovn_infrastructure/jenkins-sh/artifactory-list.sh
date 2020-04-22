#!/bin/bash
# lookup artifactory information  artifactory-list.sh
#

# Here is a simple shellscript that will output the list of Clearing tarballs
# The default is only to output the latest, however you can get more if you pass a number of lines where num > 1
# We can update the sortability criteria based on the filename format,
# the current assumption is that the naming convention is numeric sortable
#
# THIS assumes that jq package is available to parse the JSON that is output from the artifactory API call
#

# allow for a parameter (num) that is used for limiting the items in the list
num="$1"
re='^[1-9]$'
if ! [[ $1 =~ $re ]] ; then
   num=1                # Here is the default for the list (only show the last in the list)
fi

# lookup the directory list from artifactory

# If required, use the header authentication from  the OVN service user
#    curl -o temp.json -H "X-JFrog-Art-Api:AKCp5ZjpcJUYrqpvnf2SjipvQcX6Hct729RxJM3p79uWWgkBnqfMBPzoE34Aq6vKsKQdjJdh7" -XGET https://artifactory.trusted.visa.com/api/storage/ovn-app-el7/
#
    curl -o /tmp/temp.json -XGET https://artifactory.trusted.visa.com/api/storage/ovn-app-el7/ 2>/dev/null
    # parse out the names of the files in this directory
    jq .children[].uri /tmp/temp.json | sed 's/^"\///g' | sed 's/"$//g' > /tmp/ovn-app-el7.txt

    # Application specific sort in reverse order
    grep 'ovn_clearing_xdc_sync-0' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep 'ovn_cas_tools-v0' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep 'ovn_clearing_jobs-0' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep 'ovn_nginx_auth-v0' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'bridgeeafetch-.*rpm' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'cfprocessor-.*rpm' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_switch-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_mediator-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_umf_delivery-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_multidc_sync-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_vitalsigns_delivery-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'ovn_vip_ef_sync-0.*.tar.gz' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'vss-2.*rpm' /tmp/ovn-app-el7.txt | sort -n | tail -$num
    grep -x 'vsswrapper-0.*rpm' /tmp/ovn-app-el7.txt | sort -n | tail -$num
