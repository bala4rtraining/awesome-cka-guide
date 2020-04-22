#!/usr/bin/env bash
# File: epic_file_from_templates.sh
# Purpose:
#     This file generates Epic files from Epic templates or other Epics
#     The hosts file is always generated from the j2 templates.
#     The vars files can be generated either from j2 templates or other epics.
# To run script:
#     ./epic_file_from_templates.sh config_file
#
# Options:
#     configuration file mentioning hosts, epic name, template type and epic to
#     construct vars from.


function generate_definitions_yaml() {

  local config_file=$1
  local defs_file=$2
  local raw_epic_name=$(sed -n 's/^epic_name=//p' $config_file)
  local epic_name=$(echo "$raw_epic_name" | tr '[:upper:]' '[:lower:]')

  # If definitions file exists delete it and generate new one.
  if [[ -f $defs_file ]]; then
    rm $defs_file
  fi
  touch $defs_file
  echo "Created definitions file."
  echo "epic_name: '"$epic_name"'" >> $defs_file
  local epic_name_caps=$(echo "$epic_name" | tr '[:lower:]' '[:upper:]')
  echo "epic_name_caps: '"$epic_name_caps"'" >> $defs_file

  #Check if hosts in DC1 are available
  echo 'vm_dc1_name:' >> $defs_file
  vm_dc1=$(sed -n 's/^vm_dc1=//p' $config_file)
  for hname in $(echo $vm_dc1 | sed "s/,/ /g"); do
    ping -o $hname > /dev/null
    status_host=$?
    if [[ $status_host == 0 ]]; then
      echo "  - '"$hname"'" >> $defs_file
    else
      echo "Error reaching host"
      exit 3
    fi
  done

  echo 'vm_dc1_ip:' >> $defs_file
  for hname in $(echo $vm_dc1 | sed "s/,/ /g"); do
    ip=$(ping -c1 $hname | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')
    echo $hname
    echo $ip
    echo "  - '"$ip"'" >> $defs_file
  done

  echo 'vm_dc2_name:' >> $defs_file
  vm_dc2=$(sed -n 's/^vm_dc2=//p' $config_file)
  for hname in $(echo $vm_dc2 | sed "s/,/ /g"); do
    ping -o $hname > /dev/null
    status_host=$?
    if [[ $status_host == 0 ]]; then
      echo "  - '"$hname"'" >> $defs_file
    else
      echo "Error reaching host"
      exit 3
    fi
  done

  echo 'vm_dc2_ip:' >> $defs_file
  for hname in $(echo $vm_dc2 | sed "s/,/ /g"); do
    ip=$(ping -c1 $hname | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p')
    echo $hname
    echo $ip
    echo "  - '"$ip"'" >> $defs_file
  done
}


function generate_from_template() {
  local filename=$1
  local location=$2

  outputfilename=$(basename $filename .j2)
  $(jinja2 $location'/'$filename $definitions_yaml > $location'/'$outputfilename)
  rm $location'/'$filename

}

function scan_replace_templates() {
  local cur_directory=$1
  for dir in $(ls $cur_directory)
  do
    if [[ -d $cur_directory'/'$dir ]]; then
      if [[ $dir == epicname ]]; then
        mv $cur_directory'/'$dir $cur_directory'/'$epic_name
        scan_replace_templates $cur_directory'/'$epic_name
      else
        scan_replace_templates $cur_directory'/'$dir
      fi
    elif [[ -f $cur_directory'/'$dir ]]; then
      if [[ ${dir: -3} == ".j2"  ]]; then
        generate_from_template $dir $cur_directory
      fi
    fi
  done
}


temp_working_dir=temp_working_dir
if [ -d $temp_working_dir ]; then
  rm -rf $temp_working_dir
fi
mkdir $temp_working_dir

config_file=$1
if [ -f config_file ]; then
  echo "Config File not found."
fi

epic_template_dir=$(sed -n 's/^epic_template_dir=//p' $config_file)
raw_epic_name=$(sed -n 's/^epic_name=//p' $config_file)
epic_name=$(echo "$raw_epic_name" | tr '[:upper:]' '[:lower:]')
raw_construct_from=$(sed -n 's/^construct_vars_from=//p' $config_file)
construct_from=$(echo "$raw_construct_from" | tr '[:upper:]' '[:lower:]')
echo 'Generating epic files for '$epic_name
echo 'Epic type is '$epic_template_dir
if [[ $construct_from -eq null ]]; then
  echo "Building vars and hosts files from templates."
else
  echo 'construct_from is '$construct_from
fi
epic_directory="$(dirname "$(pwd)")"
# echo 'Generating files at '$epic_directory

definitions_yaml=$temp_working_dir'/temp_defs.yaml'

set -e
generate_definitions_yaml $config_file $definitions_yaml
set +e
cat $definitions_yaml
if [ ! -d $epic_directory ]; then
  echo "Parent directory should be ovn_infrastructure"
  exit 1
fi
if [ ! -d $epic_directory'/inventories' ] || [ ! -d $epic_directory'/ovn_vars' ]; then
  echo "Cannot locate ovn_infrastructure/inventories or ovn_infrastructure/ovn_vars from ovn_infrastructure/inventory_file_generator"
  exit 1
fi
if [ -d $epic_directory'/inventories/'$epic_name ]; then
  echo "Epic with name "$epic_name" exists in ovn_infrastructure/inventories"
  exit 1
fi

if [ -d $epic_directory'/ovn_vars/'$epic_name ]; then
  echo "Epic with name "$epic_name" exists in ovn_infrastructure/ovn_vars"
  exit 1
fi

# TODO add more templates.
if [[ -d $epic_directory'/inventory_file_generator/templates/'$epic_template_dir ]]; then
  template_directory=$epic_directory'/inventory_file_generator/templates/'$epic_template_dir
else
  echo $epic_directory'/inventory_file_generator/templates/'$epic_template_dir
  echo "Above path is invalid or epic_template_dir not defined."
  exit 1
fi


# Constructing from templates
if [[ $construct_from -eq null ]]; then
  # Make Hosts files from templates.
  cp -a $template_directory'/inventories/epicname' $epic_directory'/inventories/'
  mv $epic_directory'/inventories/epicname' $epic_directory'/inventories/'$epic_name
  scan_replace_templates $epic_directory'/inventories/'$epic_name
  echo "Generated hosts files at "$epic_directory'/inventories/'$epic_name
  echo "generated hosts files from templates."

  # Make Vars files from templates.
  cp -a $template_directory'/ovn_vars/epicname' $epic_directory'/ovn_vars/'
  mv $epic_directory'/ovn_vars/epicname' $epic_directory'/ovn_vars/'$epic_name
  scan_replace_templates $epic_directory'/ovn_vars/'$epic_name
  echo "Generated vars files at "$epic_directory'/ovn_vars/'$epic_name
  echo "generated vars files from templates."
else
  if [ ! -d $epic_directory'/ovn_vars/'$construct_from ]; then
    echo "Epic with name "$construct_from" cannot be found"
    exit 1
  fi
  # Make Hosts files from templates
  cp -a $template_directory'/inventories/epicname' $epic_directory'/inventories/'
  mv $epic_directory'/inventories/epicname' $epic_directory'/inventories/'$epic_name
  scan_replace_templates $epic_directory'/inventories/'$epic_name
  echo "Generated hosts files at "$epic_directory'/inventories/'$epic_name
  echo "generated hosts files from templates."
  # Make Vars from the mentioned epic
  # epic_vars=$epic_directory'/'$epic_name'/ovn_vars'
  mkdir $epic_directory'/ovn_vars/'$epic_name
  for dir in $(ls $epic_directory'/ovn_vars/'$construct_from); do
    cp -a $epic_directory'/ovn_vars/'$construct_from'/'$dir $epic_directory'/ovn_vars/'$epic_name
  done
  epic_vars=$epic_directory'/ovn_vars/'$epic_name
  grep -rl $construct_from $epic_vars | xargs sed -i.bak 's/'$construct_from'/'$epic_name'/g'
  caps_construct_from=$(echo "$construct_from" | tr '[:lower:]' '[:upper:]')
  caps_epic_name=$(echo "$epic_name" | tr '[:lower:]' '[:upper:]')
  grep -rl $caps_construct_from $epic_vars | xargs sed -i.bak 's/'$caps_construct_from'/'$caps_epic_name'/g'
  find $epic_vars -type f -name "*.bak" -exec rm -f {} \;
  echo "Generated vars files at "$epic_directory'/ovn_vars/'$epic_name
  echo "generated vars files from "$construct_from
fi
rm -rf $temp_working_dir
echo "Generated Inventory files and vars file for "$epic_name
