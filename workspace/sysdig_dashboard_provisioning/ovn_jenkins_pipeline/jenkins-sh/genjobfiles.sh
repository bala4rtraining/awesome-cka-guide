#!/bin/bash
# File:      genjobfiles.sh
# Purpose:   1. generate the job config.xml files for jenkins
#            2. reading the data from the cd_pipeline directory
#            3. use the jinja2 formatted template
# Requirements:
#            1. python + jinja2 command line interface
#

jobtemplate=$1
jenkinsfiledir=$2
outputdir=$3
gitrepourl='ssh://git@stash.trusted.visa.com:7999/op/ovn_jenkins_pipeline'
if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# run through the directory
function generatejobs () {
    local templatefile=$1
    local jenkinsfiledir=$2
    local outputdir=$3
    local ymldefsfile=$outputdir/myconfig.yaml
    local today=$(date +'%Y-%m-%d')

    for filename in $jenkinsfiledir/*.jenkinsfile; do

        jobname=${filename%.jenkinsfile}
        jobname=${jobname#$jenkinsfiledir/}
        description="Jenkins pipeline job created from standard template on $today to call $jobname"

        printf '"jobfile": %s\n' ${filename} > $ymldefsfile
        printf '"description": %s\n' "${description}" >> $ymldefsfile
        printf '"gitrepourl": %s\n' ${gitrepourl} >> $ymldefsfile
        mkdir $outputdir/$jobname

        out=$(jinja2 $templatefile $ymldefsfile > $outputdir/$jobname/config.xml)
        if [ $? ]; then
            printf "Created config.xml for $jobname\n"
        else
             (>&2 printf "Failed to create $jobname/config.xml\n")
        fi
        [ -z $out ] || printf "$out\n"

     done
}


## check pre-requisites, then execute generation of config.xml files
##
if [ ! -f "$jobtemplate" ]; then
    echo "$jobtemplate not found"
    exit 2
else
    if [ ! -d $outputdir ]; then
       mkdir $outputdir
    fi
    generatejobs $jobtemplate $jenkinsfiledir $outputdir
fi
