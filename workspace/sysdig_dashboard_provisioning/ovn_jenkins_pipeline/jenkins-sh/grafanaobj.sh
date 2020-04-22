#!/bin/sh
#
# File:      grafanaobj.sh
# Purpose:   1. Download grafana objects from the grafana server to create a tar.gz file
#            2. Upload grafana objects from tar.gz file replacing any with same filename
#            3. optionally allow for filtering (on import and export) based on filename regex
#            4. retrieve latest tarball from OVNGIT as a separate step,
#               (File was previously uploaded into OVNGIT is uploaded by jenkins release job)
#
# Requires:  jq  (json cli processor)
#

#Defaults
tarballfile="grafanaobj.tar"
fileselector='*ovn*'    # default file selector

# Options
while getopts s: opt
do
    case $opt in
        s)  fileselector=$OPTARG
        ;;
      [?])
        echo >&2 "Usage: $0 [-s fileselector] upload OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNPROD-KHE|OVNPROD-KHC|OVNPROD-DCI|OVNPROD-TELIN"
        echo >&2 "   or  $0 retrieve    OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNPROD-KHE|OVNPROD-KHC|OVNPROD-DCI|OVNPROD-TELIN \t\t\t(get last tarball from OVNGIT)"
        echo >&2 "   or: $0 maketarball OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNPROD-KHE|OVNPROD-KHC|OVNPROD-DCI|OVNPROD-TELIN \t\t\t(make a tarball)"
        echo >&2 " Note: when using a wildcard fileselector, use doublequotes e.g. -s\"s.OVN*\" "
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1 ))  # remove options leave arguments

# positional parameters
function_type=$1
ovnenvironment=$2
case $ovnenvironment in
OVNDEV)
    grafana_url="https://ovndev:OpenVisaNetDev@ovndev.visa.com/grafana"
    ;;
OVNTEST)
    grafana_url="https://ovndev:OpenVisaNetDev@ovntest.visa.com/grafana"
    ;;
OVNTEST1)
    grafana_url="https://ovndev:OpenVisaNetDev@ovntest.visa.com:8443/grafana-test1"
    ;;
OVNTEST2)
    grafana_url="https://ovndev:OpenVisaNetDev@ovntest.visa.com:8443/grafana-test2"
    ;;
OVNCERT)
    grafana_url="https://ovndev:OpenVisaNetDev@ovncert.visa.com:8443/grafana"
    ;;
OVNPROD-KHE)
    grafana_url="https://ovndev:OpenVisaNetDev@sl73ovnmgp01.visa.com:8443/grafana"
    ;;
OVNPROD-KHC)
    grafana_url="https://ovndev:OpenVisaNetDev@sl73ovnmgp02.visa.com:8443/grafana"
    ;;
OVNPROD-DCI)
    grafana_url="https://ovndev:OpenVisaNetDev@sl73ovnmgp01.visa.com:8444/grafana-dci"
    ;;
OVNPROD-TELIN)
    grafana_url="https://ovndev:OpenVisaNetDev@sl73ovnmgp02.visa.com:8444/grafana-telin"
    ;;
*)
    echo "== Environment will default to OVNDEV =="
    ovnenvironment="OVNDEV"
    grafana_url="https://ovndev:OpenVisaNetDev@ovndev.visa.com/grafana"
    ;;
esac

# Define the export function which will export objects from grafana (used when backing up)
function exportobjs() {
    url=$1           # here is the grafana_url
    tarball=$2       # output file
    selector=$3      # file selection allowing wildcard
    touch $tarball   # start with it empty
    mkdir .workdir   # make a working directory
    count=0
    printf "Starting export+download of grafana objects\n"
    printf "\tExport will pull objects from grafana URL:\t%s\n" "$url"
    printf "\tExport will filter using:                       \t%s\n" "$selector"
#   Authkey="Authorization: Bearer eyJrIjoiTzBBN2RCNURRZVZYYnpiRkF3d2JqNU90bDFOdFd3N2kiLCJuIjoiamVua2lucyIsImlkIjoxfQ=="
#   Authkey='Authorization: Bearer eyJrIjoib3owZVRBcFdZem1yWkFpR3lRVWxCSUd2OVU0cDJlN0UiLCJuIjoiamVua2luczEiLCJpZCI6MX0='

# get the list of dashboards
    curl_resp=$(curl -k -H "Content-Type: application/json" -X GET $url/api/search -o .workdir/temp.json)
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error retrieving grafana object data from %s rc=%s\n' $url $rc
       printf 'Msg from Curl: %s\n' $curl_resp
       return 1
    fi
    jsondatalist=$(jq . .workdir/temp.json)
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error parsing the first JSON object from %s rc=%s\n' $url $rc
       return 1
    fi
    cp .workdir/temp.json DEBUG.json
    unlink .workdir/temp.json   # don't need it anymore
    num=$(printf '%s ' $jsondatalist | jq length 2>/dev/null)
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error No valid json data returned from curl call to grafana %s\n' $rc
       return 1
    fi

    for ((i=0; i < $num; i++))
    do
        uri=$(printf '%s ' $jsondatalist | jq .[$i].uri|sed 's/"//g')
        type=$(printf '%s ' $jsondatalist | jq .[$i].type|sed 's/"//g')
        slug="${uri//\//_}"
        case $type in
            'dash-db')
                filename=$(printf '%s.json' $slug)
            ;;
            *)
                echo $type: unknown >&2
                filename=$(printf '%s.json' $slug)
            ;;
        esac

        curl -k -sS -H "Content-Type: application/json" -XGET $url/api/dashboards/$uri -o .workdir/$filename
        rc=$?
        if [ "$rc" -ne 0 ]; then
           printf 'Error retrieving grafana object data from %s rc=%s\n' $url $rc
           return 1
        fi

        sel=$(ls -1 .workdir/$selector 2>/dev/null|wc -l)
        if [ "$sel" -ne  0 ]; then                          # only add it if it matches the selection criteria
            printf '\tProcessing %s\n' $filename            # send it to a file
            mv .workdir/$filename $filename
            tar -uf $tarball $filename
            count=$(($count+1))
            unlink $filename
        else
            unlink .workdir/$filename
        fi
    done
    rmdir .workdir
    gzip -f $tarball

    printf "Done: %s.gz has been created.(%d files)\n" $tarball $count
}

# Define the import function which will import objects INTO grafana (used when uploading)
function importobjs() {
    url=$1    # here is the grafana_url
    tgzinput=$2
    selector=$3
    count=0
    printf "Target grafana URL:\t%s\n" $url
    printf "\tImport will read from %s\n" $tgzinput
    printf "\tImport will filter using: %s\n" $selector
    for tempfile in $(tar -tzf $tgzinput --wildcards $selector)
    do
        tar -xzf $tgzinput "$tempfile"
        slug=$(jq .meta.slug $tempfile| sed 's/"//g')
        type=$(jq .meta.type $tempfile| sed 's/"//g')
        printf '\tImporting %s (%s)\n' "$tempfile" "$slug"
        case $type in
            db)
                dashboard=$(jq '.dashboard' $tempfile|jq '.id=null')   # for the upload we need an id=null
                uploadjson=$(printf '{ "overwrite": true, "dashboard" : %s }' "$dashboard")
                http_api='api/dashboards/db'
            ;;
            *)
                echo $type: unknown >&2
                return 1
            ;;
        esac
        unlink "$tempfile"

        curl_resp=$(curl -k -H "Content-Type: application/json" -X POST -d "$uploadjson" $url/$http_api)
        rc=$?
        if [ "$rc" -ne 0 ]; then
           printf 'Error storing grafana object into %s rc=%s\n' $url $rc
           printf '%s ' $curl_resp
           printf 'Exit\n'
           return 1
        elif [ "${curl_resp/success}" = "$curl_resp" ]; then
           printf 'Unexpected Curl Response:'
           printf '%s ' $curl_resp
           printf 'Exit\n'
           return 1
        else
           count=$(($count+1))
        fi
    done
    printf 'Successful uploads: %d\n' $count
}

# Define the retrieve function, assumes OVN GIT data was uploaded and tagged using jenkins BUILD conventions
function retrieve() {
    ovnenvironment=$1    # here is the OVN environment (OVNDEV/OVNTEST/OVNPRODOCE/OVNPRODOCC)
    lastbranch=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com/git/?p=pod1;a=heads" | grep "list name"| grep 'refs/heads/build/grafanaobj' | grep "$ovnenvironment"| tr '";' "\n\n"| grep refs |head -1)
    printf 'OVNGIT last branch: %s\n' $lastbranch
    bloburl=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com/git/?p=pod1;a=commit;$lastbranch" | grep "list" | tr '"' "\n"| grep grafanaobj.tar.gz| head -1)
    retrieve=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com$bloburl" -o grafanaobj.tar.gz)
    contents=$(tar -tzf grafanaobj.tar.gz)
    printf "Contents of grafanaobj.tar.gz:\n"
    printf '\t%s\n' $contents
}

case $function_type in
    upload)
        importobjs "$grafana_url" "$tarballfile.gz" "$fileselector"
    ;;
    maketarball)
        exportobjs "$grafana_url" "$tarballfile" "$fileselector"
    ;;
    retrieve)
        retrieve "$ovnenvironment"
    ;;
    *)
        echo "\nERROR: require 'upload', 'maketarball', or 'retrieve' as first parameter\n"
        exit 1
    ;;
esac
