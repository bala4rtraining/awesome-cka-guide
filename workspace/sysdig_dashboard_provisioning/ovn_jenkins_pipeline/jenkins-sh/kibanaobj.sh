#!/bin/sh
#
# File:      kibanaobj.sh
# Purpose:   1. Download kibana objects from elasticsearch to create a tar.gz file
#            2. Upload kibana objects from tar.gz file replacing any with same filename
#            3. optionally allow for filtering (on import and export) based on filename regex
#            4. retrieve latest tarball from OVNGIT as a separate step,
#               (File was previously uploaded into OVNGIT is uploaded by jenkins release job)
#
# Requires:  jq  (json cli processor)
#            e.g. on OSX you can use "brew install jq"
#

#Defaults
tarballfile="kibanaobj.tar"
fileselector='s.*.json'    # default file selector

# Options
while getopts s: opt
do
    case $opt in
        s)  fileselector=$OPTARG
        ;;
      [?])
        echo >&2 "Usage: $0 [-s fileselector] upload OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNCERT|OVNPROD-KHC|OVNPROD-KHE|OVNPROD-DCI|OVNPROD-TELIN"
        echo >&2 "   or  $0 [-s fileselector] maketarball OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNCERT|OVNPROD-KHC|OVNPROD-KHE|OVNPROD-DCI|OVNPROD-TELIN"
        echo >&2 "   or  $0 retrieve OVNDEV|OVNTEST|OVNTEST1|OVNTEST2|OVNCERT|OVNPROD-KHC|OVNPROD-KHE|OVNPROD-DCI|OVNPROD-TELIN \t(get last tarball from OVNGIT)"
        echo >&2 " Note: when using a wildcard fileselector, use quotes e.g. -s\'s.*.json\' "
        echo >&2 "       index patterns begin with i. dashboard objects begin with d. "
        echo >&2 "       visualization objects begin with v. search objects begin with s. "
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
    elasticsearch_url="http://ovndev.visa.com/elasticsearch"
    ;;
OVNTEST)
    elasticsearch_url="https://ovntest.visa.com/elasticsearch"
    ;;
OVNTEST1)
    elasticsearch_url="https://ovntest.visa.com:8443/kibana-test1/elasticsearch"
    ;;
OVNTEST2)
    elasticsearch_url="https://ovntest.visa.com:8443/kibana-test2/elasticsearch"
    ;;
OVNCERT)
    elasticsearch_url="https://ovncert.visa.com:8443/elasticsearch"
    ;;
OVNPROD-KHE)
    elasticsearch_url="https://sl73ovnmgp01.visa.com:8443/elasticsearch"
    ;;
OVNPROD-KHC)
    elasticsearch_url="https://sl73ovnmgp02.visa.com:8443/elasticsearch"
    ;;
OVNPROD-DCI)
    elasticsearch_url="https://sl73ovnmgp01.visa.com:8444/elasticsearch-dci"
    ;;
OVNPROD-TELIN)
    elasticsearch_url="https://sl73ovnmgp02.visa.com:8444/elasticsearch-telin"
    ;;
*)
    echo "== Environment will default to OVNDEV =="
    ovnenvironment="OVNDEV"
    elasticsearch_url="http://ovndev.visa.com/elasticsearch"
    ;;
esac

# Define the export function
function exportobjs() {
    url=$1           # here is the elasticsearch_url
    tarball=$2       # output file
    selector=$3      # file selection allowing wildcard
    touch $tarball   # start with it empty
    mkdir .workdir   # make a working directory
    count=0
    printf "Starting export+download of kibana objects\n"
    printf "\tExport will pull objects from Elasticsearch URL:\t%s\n" "$url"
    printf "\tExport will filter using:                       \t%s\n" "$selector"

    curl -k -H "Content-Type: application/json" -H "kbn-version:5.0.0" -XPOST "$url/.kibana/_search" -d '{ "size": 100 }' -o .workdir/temp.json
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error retrieving kibana object data from %s rc=%s\n' $url $rc
       return 1
    fi
    jsondatalist=$(jq .hits.hits .workdir/temp.json)
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error parsing the first JSON object from %s rc=%s\n' $url $rc
       return 1
    fi
    cp .workdir/temp.json DEBUG.json
    unlink .workdir/temp.json   # don't need it anymore
    num=$(printf '%s ' "$jsondatalist" | jq length 2>/dev/null)
    rc=$?
    if [ "$rc" -ne 0 ]; then
       printf 'Error No valid json data returned from curl call to elasticsearch %s\n' $rc
       return 1
    fi

    for ((i=0; i < $num; i++))
    do
        id=$(printf '%s ' "$jsondatalist" | jq .[$i]._id |sed 's/"//g'| tr '*[]' '@')
        type=$(printf '%s ' "$jsondatalist" | jq .[$i]._type|sed 's/"//g')
        jsondata=$(printf '%s ' "$jsondatalist" | jq .[$i])   #pick the first one
        case $type in
            config)
                filename=$(printf 'c.%s.json' $id)
            ;;
            dashboard)
                filename=$(printf 'd.%s.json' $id)
            ;;
            index-pattern)
                filename=$(printf 'i.%s.json' $id)
            ;;
            search)
                filename=$(printf 's.%s.json' $id)
            ;;
            visualization)
                filename=$(printf 'v.%s.json' $id)
            ;;
            url)
                filename=$(printf 'u.%s.json' $id)
            ;;
            *)
                echo unknown kibana object type returned: $type >&2
                filename=$(printf '%s.json' $id)
            ;;
        esac

        printf '%s ' "$jsondata" > .workdir/$filename         # send it to a file
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

# Define the import function
function importobjs() {
    url=$1    # here is the elasticsearch_url
    tgzinput=$2
    selector=$3
    count=0
    printf "Target Elasticsearch URL:\t%s\n" $url
    printf "\tImport will read from %s\n" $tgzinput
    printf "\tImport will filter using: %s\n" $selector
    for tempfile in $(tar -tzf $tgzinput --wildcards $selector)
    do
        printf '\tImporting %s\n' "$tempfile"
        tar -xzf $tgzinput "$tempfile"
        id=$(jq ._id $tempfile| sed 's/"//g' | sed 's/\[/%5B/g' | sed 's/\]/%5D/g') #allow square brackets
        type=$(jq ._type $tempfile| sed 's/"//g')
        source=$(jq ._source $tempfile)
        unlink "$tempfile"
        curl_resp=$(curl -k -H "Content-Type: application/json" -H "kbn-version:5.0.0" -X PUT -d "$source" $url/.kibana/$type/$id)
        rc=$?
        if [ "$rc" -ne 0 ]; then
           printf 'Error storing kibana object into %s rc=%s\n' $url $rc
           printf '%s ' $curl_resp
           printf 'Exit\n'
           return 1
        elif [ "${curl_resp/successful}" = "$curl_resp" ]; then
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

# Define the retrieve function
function retrieve() {
    ovnenvironment=$1    # here is the OVN environment (OVNDEV/OVNTEST/OVNPRODOCE/OVNPRODOCC)
    lastbranch=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com/git/?p=pod1;a=heads" | grep "list name"| grep 'refs/heads/build/kibanaobj' |grep "$ovnenvironment"| tr '";' "\n\n"| grep refs |head -1)
    printf 'OVNGIT last branch: %s\n' $lastbranch
    bloburl=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com/git/?p=pod1;a=commit;$lastbranch" | grep "list" | tr '"' "\n"| grep kibanaobj.tar.gz| head -1)
    retrieve=$(curl -s -f -XGET "https://sl55ovnapq01.visa.com$bloburl" -o kibanaobj.tar.gz)
    contents=$(tar -tzf kibanaobj.tar.gz)
    printf "Contents of kibanaobj.tar.gz:\n"
    printf '\t%s\n' $contents
}

case $function_type in
    upload)
        importobjs "$elasticsearch_url" "$tarballfile.gz" "$fileselector"
    ;;
    maketarball)
        exportobjs "$elasticsearch_url" "$tarballfile" "$fileselector"
    ;;
    retrieve)
        retrieve "$ovnenvironment"
    ;;
    *)
        echo "\nERROR: require 'upload', 'maketarball', or 'retrieve' as first parameter\n"
        exit 1
    ;;
esac


