#!/bin/bash

help() {
  cat - <<EOM
  Use: bash smoke_test.sh [--help] HOSTNAME
    ex 1: bash smoke_test.sh localhost
    ex 2: bash smoke_test.sh --help
EOM
}

curly() {
  local url=''
  local service=''
  local result='unknown'
  
  url="$1"
  shift
  service="$1"
  result="$(curl -k -s -i -X GET "$url" | head -1 | awk '{ print $2 }')"
  echo "$result  $service  $url"
  if [[ "$result" == "200" ]]; then
    return 0
  fi
  return 1
}


if [[ $# -lt 1 || "$1" =~ -*help ]]; then
  help
  exit 0
fi

proto=https://
hostname="$1"
shift

if [[ "$hostname" =~ ^https{0,1}:// ]]; then
  # hostname include protocol
  proto=""
fi

result=0
curly "${proto}${hostname}/index.html" "portal"
if [[ $? != 0 ]]; then result=$?; fi
curly "${proto}${hostname}/user/.well-known/jwks" "fence"
if [[ $? != 0 ]]; then result=$?; fi
curly "${proto}${hostname}/index/_status" "indexd"
if [[ $? != 0 ]]; then result=$?; fi
curly "${proto}${hostname}/peregrine/_status" "peregrine"
if [[ $? != 0 ]]; then result=$?; fi
curly "${proto}${hostname}/api/_status" "sheepdog"
if [[ $? != 0 ]]; then result=$?; fi
curly "${proto}${hostname}/pidgin/_status" "pidgin"
if [[ $? != 0 ]]; then result=1; fi
exit $result
