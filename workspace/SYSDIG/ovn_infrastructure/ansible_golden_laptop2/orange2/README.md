#
# Top level playbooks and variables
#

The rescue playbooks runs locally on the rescue server to set up
interfaces, dhcp server, tftp server, http server, pxe and onie
etc. The intent is for the rescue to install OOB SW, OOB Server, other
switches and servers.

The cumulus will be run on rescue to set up all Cumulus switches
The haproxy will be run on rescue to set up 2 HAproxy nodes

HP servers should be able to be automatically installed by rescue with DHCP assigned static IPs

site specific variables should be kept here in ovn_common_<site>.yml files
