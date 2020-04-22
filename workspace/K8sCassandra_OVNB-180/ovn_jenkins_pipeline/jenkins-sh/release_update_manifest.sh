#!/bin/bash
#File: release_update_manifest.sh
# Purpose:
#     To update Release_manifest using jenkins parameters
# To run script:
#     ./release_update_manifest.sh path/to/ovn-vars-release_mainfest.yml

release_manifest_path=$1

if [[ -d $1 ]]; then
  echo "Invalid path($1) "
  exit 1
fi
anyUpdates=false
regexvalid='^[a-zA-Z_0-9.\+-]+$'
variableNames=(OVN_MEDIATOR_REF OVN_SWITCH_REF OVN_UMF_DELIVERY_REF OVN_MULTIDC_SYNC_REF OVN_VITALSIGNS_DELIVERY_REF OVN_VIP_EF_SYNC_REF OVN_CLEARING_JOBS_TARBALL OVN_CLEARING_XDC_SYNC_TARBALL OVN_CAS_TOOLS_TARBALL OVN_CAS_UI_TARBALL OVN_NGINX_AUTH_TARBALL OVN_SWITCH_TARBALL OVN_MEDIATOR_TARBALL OVN_VITALSIGNS_DELIVERY_TARBALL OVN_UMF_DELIVERY_TARBALL OVN_MULTIDC_SYNC_TARBALL OVN_VIP_EF_SYNC_TARBALL)
nameInFile=(mediator_ovngit_ref switch_ovngit_ref umf_delivery_ovngit_ref multidc_sync_ovngit_ref vitalsigns_ovngit_ref vip_ef_sync_ovngit_ref ovn_clearing_jobs_tarball ovn_clearing_xdc_sync_tarball ovn_cas_tools_tarball ovn_cas_ui_tarball ovn_nginx_auth_tarball ovn_switch_tarball ovn_mediator_tarball ovn_vitalsigns_delivery_tarball ovn_umf_delivery_tarball ovn_multidc_sync_tarball ovn_vip_ef_sync_tarball)
arraylength=${#variableNames[@]}
for (( i=1; i<${arraylength}+1; i++ ));
do
  eval enteredVal=\$${variableNames[$i-1]}
  fileKey=${nameInFile[$i-1]}

  isInFile=$(cat $release_manifest_path | grep -c "$fileKey")
  if [[ $isInFile -ne 0 ]] && [[ $enteredVal =~ $regexvalid ]]; then
    anyUpdates=true
    sed -i -e '/'$fileKey'/s/'$fileKey': .*/'$fileKey': "'$enteredVal'"/g' $release_manifest_path
  elif [[ $enteredVal =~ $regexvalid ]]; then
    anyUpdates=true
    echo $fileKey ': "'$enteredVal'"' >> $release_manifest_path
  fi
done
if [ $anyUpdates == false ]; then
  echo " No new updates found"
  exit 1
fi
