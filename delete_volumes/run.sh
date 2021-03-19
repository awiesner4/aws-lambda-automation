#!/usr/bin/env bash

#source "${HOME}/.concord/default.infra.ck8s"
source "${PWD}/.tools/functions.bash"
projectName="delete-available-volumes-lambda"
entryPoint="-F entryPoint=default"
mustacheBin="${PWD}/.tools/mustache"
target="${PWD}/target"

function cmd() {
  basename $0
}

function usage() {
  echo "\
`cmd` [OPTIONS...]
-h, --help; Show help
-y, --yaml; request yaml to use
-f, --flow; Run the specified release flow
" | column -t -s ";"
}

options=$(getopt -o h,f:,o: --long help,yaml:,flow: -n 'parse-options' -- "$@")

if [ $? != 0 ]; then
  echo "Failed parsing options." >&2
  exit 1
fi

while true; do
  case "$1" in
    -h | --help) usage; exit;;
    -y | --yaml) concordYml=$2; shift 2;;
    -f | --flow) flow=$2; shift 2;;
    -- ) shift; break ;;
    "" ) break ;;
    * ) echo "Unknown option provided ${1}"; usage; exit 1; ;;
  esac
done

[ -z $concordYml ] && echo && echo "You must specify a Concord yaml file with the -y/--yaml option." && echo && exit
[ ! -f $concordYml ] && echo && echo "The specified Concord yaml[$concordYml] doesn't exist." && echo && exit

# This allows us to start with any arbitrary Concord flow
[ ! -z "$flow" ] && entryPoint="-F entryPoint=${flow}"

if cat $concordYml | grep "flowTemplate" > /dev/null; then
  flowTemplate=$(cat $concordYml | grep "flowTemplate" | cut -d ":" -f 2 | tr -d ' \n\r\t')
  templateFile="${PWD}/templates/${flowTemplate}.yml.mustache"
  [ ! -f ${templateFile} ] && echo && echo "The specified Concord yaml[$concordYml] referes flowTemplate[${flowTemplate}] that doesn't exist." && echo && exit
fi

if cat $concordYml | grep "organization" > /dev/null; then
  ORGANIZATION=$(cat $concordYml | grep "organization" | cut -d ":" -f 2 | tr -d ' \n\r\t')
fi

# Clear and recreate target dir.
if [ -d ${target} ]; then
  rm -rf ${target}/*
else
  mkdir ${target}
fi

targetConcordYaml="${target}/input.yaml"
cp ${concordYml} ${targetConcordYaml}

finalConcordYaml="${target}/concord.yml"
if [ ! -z ${templateFile} ]; then
  # If template provided render flow using template (Mustache) treating input yaml as mustache variables
  cat "${targetConcordYaml}" | $mustacheBin ${templateFile} > ${finalConcordYaml}
  rm "${targetConcordYaml}"
else
  mv "${targetConcordYaml}" "${finalConcordYaml}"
fi

cd ${target} && zip -r payload.zip ./* > /dev/null && cd ..

concord_organization ${ORGANIZATION}
concord_project ${projectName}

curl --http1.1 -L -i -H "Authorization: ${CONCORD_API_TOKEN}" \
 -F "archive=@${target}/payload.zip" \
 -F "org=${ORGANIZATION}" \
 -F "project=${projectName}" \
 ${entryPoint} \
 ${CONCORD_URL}/api/v1/process
