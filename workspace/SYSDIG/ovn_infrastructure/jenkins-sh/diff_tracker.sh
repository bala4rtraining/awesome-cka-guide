#!/usr/bin/env bash
# File: Diff_tracker.sh
# Purpose:
#     To compare hosts, vars, roles between ovn_app_infrastructure and ovn_infrastructure.
#     This excludes comparing the playbooks. Enable roles comparision using -o
# To run script:
#     ./Diff_tracker.sh location/of/ovn_app_infrastructure location/of/ovn_infrastructure
#
# Options:
#     -p: To compare playbooks
#     -h: Generate HTML files
#     -x: Generate XML files
#     -s: Generate summary files

function parse_diff_strings()
{
  # sample string: 12,14c22,24
  # This implies lines 12-14 in app_directory changed from lines 22-24 in ovn_directory
  # d implies Deletions and a implies Additions in ovn_directory
  local string=$1
  #echo $string >> $sum_dir
  if [[ $string =~ ^([0-9]+),([0-9]+)([a-z])([0-9]+),([0-9]+) ]]; then
    # add counts
    local start1=${BASH_REMATCH[1]} # Start line number file 1
    local end1=${BASH_REMATCH[2]} # End line number file 1
    local char=${BASH_REMATCH[3]} # The character defining diff
    #start2=${BASH_REMATCH[4]} # Start line number file 2
    # end2=${BASH_REMATCH[5]} # End line number file 2
    if [[ $char == 'c' ]]; then
      let "changes_counter=changes_counter+end1-start1"
    else
      echo $string
      echo "Shouldn't happen" # TODO comment out
    fi
  elif [[ $string =~ ^([0-9]+),([0-9]+)([a-z])([0-9]+) ]]; then
    local start1=${BASH_REMATCH[1]} # Start line number file 1
    local end1=${BASH_REMATCH[2]} # End line number file 1
    local char=${BASH_REMATCH[3]} # The character defining diff
    #start2=${BASH_REMATCH[4]} # Start line number file 2
    if [[ $char == 'd' ]]; then
      let "deletion_counter=deletion_counter+end1-start1"
    elif [[ $char == 'c' ]]; then
      let "changes_counter=deletion_counter+end1-start1"
    else
      echo $string
      echo "Shouldn't happen" # TODO comment out
    fi
  elif [[ $string =~ ^([0-9]+)([a-z])([0-9]+),([0-9]+) ]]; then
    # start1=${BASH_REMATCH[1]} # Start line number file 1
    local char=${BASH_REMATCH[2]} # The character defining diff
    local start2=${BASH_REMATCH[3]} # Start line number file 2
    local end2=${BASH_REMATCH[4]} # End line number file 2
    if [[ $char == 'a' ]]; then
      let "addition_counter=addition_counter+end2-start2"
    elif [[ $char == 'c' ]]; then
      let "changes_counter=changes_counter+end2-start2"
    else
      echo $string
      echo "Shouldn't happen" # TODO comment out
    fi
  elif [[ $string =~ ^([0-9]+)([a-z])([0-9]+) ]]; then
    let "changes_counter++"
  else
    echo $string
    echo "Shouldn't happen" # TODO comment out
  fi
}

function is_hosts ()
{
  if [[ $dir == "hosts" ]]; then
    return 1
  else
    return 0
  fi
}

function is_vars ()
{
  if [[ $dir == *.yml ]] || [[ $dir == *.j2 ]]; then
    #echo $dir
    return 1
  else
    #echo "Not matched" $dir
    return 0
  fi
}

function is_roles ()
{
  if [[ $dir == *.yml ]] || [[ $dir == *.j2 ]]; then
    return 1
  else
    return 0
  fi
}

function is_playbooks ()
{
  if [[ $dir == *.yml ]]; then
    return 1
  else
    return 0
  fi
}

function function_caller() {
  # echo $@
  "$@";
  returned_val=$?
  return $returned_val
 }

function compare_directories()
{
  # Directory from ovn_app_infrastructure
  local app_directory=$1
  # Directory from ovn_infrastructure
  local ovn_directory=$2
  # Pass the function which checks if the file name is a role or vars or playbooks based on its name.
  local checker_func=$3
  # # 1 if need xml, any other if not needed
  # local need_xml=$4
  # # 1 if need html, any other if not needed
  # local need_html=$5
  # # 1 if need summary, any other if not needed
  # local need_summary=$6

  local dir=""
  for dir in $(ls $ovn_directory)
  do
    # echo $checker_func $dir
    function_caller $checker_func $dir
    local is_specified_type=$?
    if [ -d $ovn_directory/$dir ] && [ -d $app_directory/$dir ]; then
      if [[ $need_html == 1 ]]; then
        echo '<div class="panel panel-default">' >> $op_html # For HTML
        echo '<div class="panel-heading"><h4 class="panel-title"><a data-toggle="collapse" href="#collapsereferencer">'$dir'</a></h4></div>' >> $op_html
        echo '<div class="collapse" id="collapsecapturer">' >> $op_html
        echo '<div id=""  class="panel-body ">' >> $op_html
      fi
      if [[ $need_xml == 1 ]]; then
        echo "<directory name="\'$dir\'">" >> $op_dir
      fi

      compare_directories $app_directory/$dir $ovn_directory/$dir $checker_func

      if [[ $need_html == 1 ]]; then
        echo '</div></div></div>' >> $op_html
      fi
      if [[ $need_xml == 1 ]]; then
        echo "</directory>" >> $op_dir
      fi
    elif [[ $is_specified_type == 1 ]] && [ -f $ovn_directory/$dir ] && [ -f $app_directory/$dir ]; then
        # Change directory and find the date when the document has beeen changed.
        curr_dir=$(pwd)
        cd $app_directory
        if [[ $(git log $dir | sed -n '3p') =~ ([a-zA-Z]{3} [0-9]{1,2}) ]]; then
          d1=${BASH_REMATCH[1]}
        fi
        cd $curr_dir
        cd $ovn_directory
        if [[ $(git log $dir | sed -n '3p') =~ ([a-zA-Z]{3} [0-9]{1,2}) ]]; then
          d2=${BASH_REMATCH[1]} ${BASH_REMATCH[2]}
        fi
        cd $curr_dir
        # Add all opening tags
        if [[ $need_xml == 1 ]]; then
          echo "<file name='$dir' app_date_changed='$d1' ovn_date_changed='$d2'>" >> $op_dir
        fi
        if [[ $need_html == 1 ]]; then
          echo '<div class="panel panel-default">' >> $op_html # For HTML
          echo '<div class="panel-heading"><h4 class="panel-title"><a data-toggle="collapse" href="#collapsereferencer">'$dir'</a></h4></div>' >> $op_html
          echo '<div class="collapse" id="collapsecapturer">' >> $op_html
          echo '<div id=""  class="panel-body ">' >> $op_html
        fi
        if [[ $(diff -q  $app_directory/$dir $ovn_directory/$dir | wc -c) -ne 0 ]]; then
          echo Changes=$changes_counter, Additions=$addition_counter, Deletions=$deletion_counter, app_date_changed=$d1, ovn_date_changed=$d2, Filename=$app_directory/$dir
          # Add all content between tags
          if [[ $need_summary == 1 ]]; then
            let "diff_counter++" # TODO summary
            changes_counter=0
            deletion_counter=0
            addition_counter=0
            for st in $(diff $app_directory/$dir $ovn_directory/$dir | grep '^[1-9]') # O# TODO summary
            do
              parse_diff_strings $st
            done
            echo Changes=$changes_counter, Additions=$addition_counter, Deletions=$deletion_counter, app_date_changed=$d1, ovn_date_changed=$d2, Filename=$app_directory/$dir >> $sum_dir
          fi
          if [[ $need_xml == 1 ]]; then
            diff $app_directory/$dir $ovn_directory/$dir | sed s/'<'/'\&lt;'/g | sed s/'>'/'\&gt;'/g >> $op_dir
          fi
          if [[ $need_html == 1 ]]; then
            echo '<p> app_infrastructure date changed: '$d1'</p>' >> $op_html
            echo '<p> ovn_infrastructure date changed: '$d2'</p>' >> $op_html
            echo '<code>' >> $op_html # For html
            diff $app_directory/$dir $ovn_directory/$dir | sed s/'<'/'\&lt;'/g | sed s/'>'/'\&gt;'/g | sed 's/$/<br \/>/' >> $op_html # For html
            echo '</code>' >> $op_html # For html
          fi

        fi
        # Add all closing tags
        if [[ $need_xml == 1 ]]; then
          echo "</file>" >> $op_dir
        fi
        if [[ $need_html == 1 ]]; then
          echo '</div></div></div>' >> $op_html # For html
        fi
      fi
  done
}


diff_roles=false
need_summary=0
need_xml=0
need_html=0
while getopts "hxsp" name
do
  case $name in
    h)
      need_html=1
      ;;
    x)
      need_xml=1
      ;;
    s)
      need_summary=1
      ;;
    p)
      diff_roles=true
      ;;
    \?)echo "Invalid arg";;
  esac
done

shift $(($OPTIND -1))

root_app=$1
root_vanilla=$2
echo diff_roles=$diff_roles
echo root_app=$root_app
echo root_vanilla=$root_vanilla
echo need_xml=$need_xml
echo need_html=$need_html
echo need_summary=$need_summary

temp_folder=temp
mkdir $temp_folder

diff_counter=0

if [[ $need_summary == 1 ]]; then
  sum_dir=$temp_folder/"hosts_dif_summary.txt"
fi
if [[ $need_xml == 1 ]]; then
    op_dir=$temp_folder/"hosts_dif.xml"
    echo '<hosts>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  op_html=$temp_folder/"hosts_dif.html"
  cat jenkins-sh/headerdata.txt > $op_html
fi

compare_directories $root_app/inventories $root_vanilla/inventories is_hosts

echo %% The number of hosts files that differ are $diff_counter
if [[ $need_summary == 1 ]]; then
  echo %% The number of hosts files that differ are $diff_counter >> $sum_dir
fi
if [[ $need_xml == 1 ]]; then
  echo '</hosts>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  echo '</div></body></html>' >> $op_html
  awk '{for(x=1;x<=NF;x++)if($x~/referencer/){sub(/referencer/,++i)}}1' $op_html > t1.txt
  awk '{for(x=1;x<=NF;x++)if($x~/capturer/){sub(/capturer/,++i)}}1' t1.txt > $op_html
fi


diff_counter=0

if [[ $need_summary == 1 ]]; then
  sum_dir=$temp_folder/"vars_dif_summary.txt"
fi
if [[ $need_xml == 1 ]]; then
    op_dir=$temp_folder/"vars_dif.xml"
    echo '<vars>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  op_html=$temp_folder/"vars_dif.html"
  cat jenkins-sh/headerdata.txt > $op_html
fi

compare_directories $root_app/app_vars $root_vanilla/ovn_vars is_vars

echo %% The number of vars files that differ are $diff_counter
if [[ $need_summary == 1 ]]; then
  echo %% The number of vars files that differ are $diff_counter >> $sum_dir
fi
if [[ $need_xml == 1 ]]; then
  echo '</vars>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  echo '</div></body></html>' >> $op_html
  awk '{for(x=1;x<=NF;x++)if($x~/referencer/){sub(/referencer/,++i)}}1' $op_html > t1.txt
  awk '{for(x=1;x<=NF;x++)if($x~/capturer/){sub(/capturer/,++i)}}1' t1.txt > $op_html
fi


diff_counter=0

if [[ $need_summary == 1 ]]; then
  sum_dir=$temp_folder/"roles_dif_summary.txt"
fi
if [[ $need_xml == 1 ]]; then
    op_dir=$temp_folder/"roles_dif.xml"
    echo '<roles>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  op_html=$temp_folder/"roles_dif.html"
  cat jenkins-sh/headerdata.txt > $op_html
fi

compare_directories $root_app/ansible_roles $root_vanilla/ansible_roles is_roles

echo %% The number of roles that differ are $diff_counter
if [[ $need_summary == 1 ]]; then
  echo %% The number of roles that differ are $diff_counter >> $sum_dir
fi
if [[ $need_xml == 1 ]]; then
  echo '</roles>' >> $op_dir
fi
if [[ $need_html == 1 ]]; then
  echo '</div></body></html>' >> $op_html
  awk '{for(x=1;x<=NF;x++)if($x~/referencer/){sub(/referencer/,++i)}}1' $op_html > t1.txt
  awk '{for(x=1;x<=NF;x++)if($x~/capturer/){sub(/capturer/,++i)}}1' t1.txt > $op_html
fi

if [[ $diff_roles == 'true' ]]; then

  diff_counter=0

  if [[ $need_summary == 1 ]]; then
    sum_dir=$temp_folder/"pbooks_dif_summary.txt"
  fi
  if [[ $need_xml == 1 ]]; then
      op_dir=$temp_folder/"pbooks_dif.xml"
      echo '<roles>' >> $op_dir
  fi
  if [[ $need_html == 1 ]]; then
    op_html=$temp_folder/"pbooks_dif.html"
    cat jenkins-sh/headerdata.txt > $op_html
  fi

  compare_directories $root_app/ansible_roles $root_vanilla/ansible_roles is_playbooks

  echo %% The number of playbooks that differ are $diff_counter
  if [[ $need_summary == 1 ]]; then
    echo %% The number of playbooks that differ are $diff_counter >> $sum_dir
  fi
  if [[ $need_xml == 1 ]]; then
    echo '</roles>' >> $op_dir
  fi
  if [[ $need_html == 1 ]]; then
    echo '</div></body></html>' >> $op_html
    awk '{for(x=1;x<=NF;x++)if($x~/referencer/){sub(/referencer/,++i)}}1' $op_html > t1.txt
    awk '{for(x=1;x<=NF;x++)if($x~/capturer/){sub(/capturer/,++i)}}1' t1.txt > $op_html
  fi
fi
