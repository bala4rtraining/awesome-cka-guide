#!/usr/bin/env bash
#

set -e

NUM=$1
VER=$2

get_jenkins_refs() {

  local BUILD_NO="$1"
  local URL="http://ci.trusted.visa.com/job/ovn/job/ovn_deploy-ovn-job/$BUILD_NO/injectedEnvVars/export"

  curl -s -f -X GET -H"Accept:text/plain" "$URL" | grep OVNGIT_REF
}

deref() {

  local REF="$1"
  local MODULE="$2"

  ssh sl55ovnapq01.visa.com cd /data/git/pod1\; git cat-file -p "$REF" |
  tr '(,)' ' ' |
  sed "/^Build-ref:/ { s/origin\///; s/^Build-ref: \([^ ]*\)  *\([^ ]*\) .*/${MODULE}_GIT_REF=\\1; ${MODULE}_GIT_BRANCH=\\2/; p; }; d"
}

check_hash_length() {

  local HASH="$1"
  local NAME="$2"

  [ ${#1} -eq 40 ] || {
    echo "Unable to dereference $NAME hash (length=${#HASH}): $HASH"
    exit 1
  }
}

bitbucket_tag() {

  local TAG="$1"
  local STASH_HASH="$2"
  local STASH_REPO="$3"


  local REPO="ssh://git@stash.trusted.visa.com:7999/op/$STASH_REPO.git"

  local DIR=`mktemp -d /tmp/ovngit.XXXXXXXXX`
  local GIT="git --git-dir=$DIR"

  trap "rm -rf $DIR; trap - RETURN" RETURN

  $GIT init -q

  #Once bitbucket/GIT is upgraded, fetch (1) by HASH, (2) shallow: add "--depth=1",
  $GIT fetch -q -k --no-tags "$REPO"
  $GIT tag "$TAG" "$STASH_HASH"
  $GIT push -q --tags "$REPO"
}

tag_release() {

  local COMPONENT="$1"
  local TAG="$2"
  local OVNGIT_REF="$3"
  local STASH_HASH="$4"
  local STASH_REPO="$5"

  ovngit_tag "$OVNGIT_REF" "release/$COMPONENT/$TAG"

  bitbucket_tag "$TAG" "$STASH_HASH" "$STASH_REPO"

  cat <<END
============================
${COMPONENT} tagged
============================
END
}

[ $# -eq 2 ] || { cat <<END
Use this to tag source and binary of ovn_deploy-ovn-job run to promote them to a <Release candidate>

Usage:
  $0 <nightly_build_no> <version>

Example:
  $0 173 v1.0rc1
END
  exit 1
}

unset MEDIATOR_OVNGIT_REF SWITCH_OVNGIT_REF UMF_DELIVERY_OVNGIT_REF

eval "`get_jenkins_refs $NUM`"

[ -z "$MEDIATOR_OVNGIT_REF" -o -z "$SWITCH_OVNGIT_REF" -o -z "$UMF_DELIVERY_OVNGIT_REF" ] && {
  echo Unable to inspect nightly build No.$NUM
  exit 1
}

eval "`deref $MEDIATOR_OVNGIT_REF MEDIATOR`"
eval "`deref $SWITCH_OVNGIT_REF SWITCH`"
eval "`deref $UMF_DELIVERY_OVNGIT_REF UMF_DELIVERY`"

check_hash_length "$MEDIATOR_GIT_REF" mediator
check_hash_length "$SWITCH_GIT_REF" switch
check_hash_length "$UMF_DELIVERY_GIT_REF" "umf delivery"

cat <<END

============================
All REFS resolved

Mediator     source: $MEDIATOR_GIT_REF, binary: $MEDIATOR_OVNGIT_REF
Switch       source: $SWITCH_GIT_REF, binary: $SWITCH_OVNGIT_REF
UMF delivery source: $UMF_DELIVERY_GIT_REF, binary: $UMF_DELIVERY_OVNGIT_REF

============================
Tagging...
============================

END

OVNGIT_PRIMARY="${OVNGIT_PRIMARY:-sl55ovnapq01.visa.com}"
source /dev/stdin <<<"`curl -x '' -s -f https://$OVNGIT_PRIMARY/git/@pod1/api/v0.5:/ovngit-lib.sh`"

tag_release mediator "$VER" "$MEDIATOR_OVNGIT_REF" "$MEDIATOR_GIT_REF" ovn_mediator

tag_release switch "$VER" "$SWITCH_OVNGIT_REF" "$SWITCH_GIT_REF" ovn

tag_release umf_delivery "$VER" "$UMF_DELIVERY_OVNGIT_REF" "$UMF_DELIVERY_GIT_REF" ovn_umf_delivery
