#!/bin/bash
#
# This script downloads the latest artifact matching the given name pattern from ovn artifactory repo to dest.
#

extract=false
strip=0

while getopts :x: opt; do
  case $opt in
    x)
      extract=true
      strip=$OPTARG
      ;;
    \?)
      exit 1
      ;;
  esac
done

shift $((OPTIND -1))

if [ $# -ne 2 ]; then
  echo "This script downloads the latest artifact matching the given name pattern from ovn artifactory repo to dest."
  echo
  echo "Usage: $0 [-x <strip-components>] <name> <dest>"
  echo
  echo "Example: Download the latest hub-detect jar file to local /opt/BD/hub-detect.jar"
  echo "$0 'hub-detect-*.jar' /opt/BD/hub-detect.jar"
  exit 1
fi

name=$1
dest=$2

set $(for url in $(curl -s "https://artifactory.trusted.visa.com/api/search/artifact?name=$name&repos=ovn" | jq -r '.results[].uri'); do curl -s $url | jq -r '[.created, .downloadUri, .checksums.sha256] | @tsv'; done | sort | tail -n 1)

download_uri=$2
checksum=$3
filename=$(basename $download_uri)

if [ "$extract" == "true" ]; then
  dest=$(echo -n $filename | sed "s#$(echo ${name/\*/\\(.*\\)})#$dest#")
  mkdir -p $dest
  if [[ "$filename" =~ \.tar\.gz$ ]] || [[ "$filename" =~ \.tgz$ ]]; then
    curl -sL $download_uri | tar -C $dest -xzf - --strip-components=$strip
  elif [[ "$filename" =~ \.tar$ ]]; then
    curl -sL $download_uri | tar -C $dest -xf - --strip-components=$strip
  elif [[ "$filename" =~ \.zip$ ]]; then
    curl -sLO $download_uri
    unzip -d $dest $filename
    rm -f $filename
  else
    echo "Unsupported archive format."
    exit 1
  fi
else
  if [ -d "$dest" ]; then
    dest="$dest/$filename"
  fi
  curl -sLo $dest $download_uri || exit 1
  echo "$checksum $dest" | sha256sum -c --quiet
fi

