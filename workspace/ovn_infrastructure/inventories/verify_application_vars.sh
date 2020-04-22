#!/bin/bash

find . -name '*.yml' -a -type f -print0 | while IFS= read -r -d '' file
do
  cat "$file" | grep -v '\\---'; echo
done > /tmp/config_vars

if [[ `uname -s` -eq "Darwin" ]]; then
  SED='sed -E'
else
  SED='sed -r'
fi

EXIT=0
for VAR in `$SED 's#(^[a-zA-Z_][a-zA-Z0-9_]*)[^:]*.*#\1#; /^[^[a-zA-Z_]/d; /^\s*$/d' /tmp/config_vars | sort | uniq`
do
  echo "-----> CHECKING \"$VAR\" <-----"
  find . -name 'dc*.yml' -print0 | while IFS= read -r -d '' file
  do
    DIR=`dirname "$file"`
    COUNT=`grep -E "^$VAR:" "$DIR"/*.yml | wc -l | xargs`
    if [[ $COUNT -gt 1 ]]; then
      echo
      echo "Expected: 1 \"$VAR\" definition, but found: $COUNT in $DIR.  Please remediate and re-run this script."
      grep -E "^$VAR:" "$DIR"/*.yml
      EXIT=1
    fi
  done
done

exit $EXIT
