#!/usr/bin/env bash
#

set -e

[ $# -eq 4 ] || { cat <<END
Use this to generate git history changelog of an OVN component

Usage:
  $0 <component_name> <stash_repo_name> <prev_version_tag> <this_version_tag>

Example:
  $0 switch ovn v1.0 v2.0
END
  exit 1
}

COMPONENT="$1"
REPO="$2"
FROM="$3"
TO="$4"

DIR=`mktemp -d /tmp/ovngit.XXXXXXXXX`
GIT="git --git-dir=$DIR"

trap "rm -rf $DIR" EXIT

$GIT init -q --bare
$GIT remote add origin ssh://git@stash.trusted.visa.com:7999/op/$REPO.git
$GIT fetch -q origin

cat <<END
### $COMPONENT $TO

$($GIT log -n1 --pretty=format:"%ci %H" $TO)
\`\`\`
$($GIT log --decorate=no --oneline ${FROM}..${TO})
\`\`\`
END
