#!/bin/bash
#
# File: BDscan.sh
# Purpose: 1.  Loop to fetch a repository name from an input text file, e.g. BDrepolist.txt
#          2.  Clone that repository on local workstation, with git command
#          3.  Construct Black duck scan command string, for a particular repository
#          4.  Run the BD scan command
# To run bash script:
#          bash ./BDscan.sh BDrepolist.txt
#
# import multiple remote git repositories to local CODE dir

# define project VERSION, reponame
# You can redefine the following two parameter values
# will result the scan results posted under your specified project and version names
project1="OVN_OVNHUB_AskNowId_0019109"
version1="_OVNHUB_visa_v1"

currentpath=$PWD
echo $currentpath

#check if one argument of input file e.g. BDrepolist.txt has been entered
if [ $# -eq 0 ]; then
echo "*** BDscan.sh bash script: No arguments provided ***"
echo "To run this bash script, provide input filename as an argument, such as:"
echo "   bash ./BDscan.sh BDrepolist.txt"
echo "BDrepolist.txt would be the input file that contains names of repositories to be scanned"
echo "One repository name per line"
echo "You can use a different input filename or modify the content of BDrepolist.txt"
echo " "
echo "You may run this from any working directory, however you need both BDscan.sh script and the input file in the same dir"
echo "You also need to download (available from Black Duck server) and unzip the scan.cli-macosx.zip from the same working dir"
exit 1
fi

#read each line within filename
filename="$1"

#BEGINNING OF LOOP TO READ EACH NAME OF REPOSITORY, CLONE REPO, BLACK DUCK SCAN THE REPO
while read -r line
do

reponame="$line"
echo "Name read from file: $reponame"

# construct git clone cmd w the reponame
gitA="git clone ssh://git@stash.trusted.visa.com:7999/ovnhub/"
gitC=".git"
gitcmd=$gitA$reponame

echo $gitcmd
gitcmd=$gitcmd$gitC
echo "Running this: "$gitcmd
$gitcmd

#go to directory reponame
cdcmd="cd "
cdcmd=$cdcmd$reponame
echo $cdcmd
echo "Running this: "$cdcmd
$cdcmd

#git checkout visa branch, and go back up one level
git checkout visa || true
cd ..

#construct partial Black duck scan command
scancmd=$currentpath"/scan.cli-3.7.1/bin/scan.cli.sh --username jenkins_ovn_bd --password Jenkins@123 --host sl73bdhubapp001.visa.com --port 443 --scheme HTTPS "

#define PROJECT name
project=$project1
echo "full project name: "$project

#define RELEASE/VERSION NAME
version=$reponame$version1
echo "full versione name: "$version

#build full BD scan command
fullscancmd=$scancmd"--project "$project" -name "$version" --release "$version" "$currentpath"/"$reponame
echo "About to print full scan cmd: "
echo $fullscancmd

#run BD scan now
echo "Running the BD Scan now :"$scancmd
eval $fullscancmd
sleep 5

done < "$filename"
#END OF LOOP FOR EACH REPO




