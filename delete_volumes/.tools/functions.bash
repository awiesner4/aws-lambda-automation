#!/usr/bin/env bash
CURL="curl -L -sS -o /dev/null "
CONCORD_API_TOKEN="$(sops exec-env ${PWD}/.tools/concord.infra.json 'echo $CONCORD_API_TOKEN')"
CONCORD_URL="$(sops exec-env ${PWD}/.tools/concord.infra.json 'echo $CONCORD_URL')"

concord_project() {
  # $1 = projectname
  echo "Creating project in organization $1..."
  $CURL -H 'Content-Type: application/json' \
   -H "Authorization: ${CONCORD_API_TOKEN}" \
   -d "{ \"name\": \"$1\", \"acceptsRawPayload\": true, \"rawPayloadMode\" : \"EVERYONE\" }" \
   ${CONCORD_URL}/api/v1/org/${ORGANIZATION}/project
}

concord_organization() {
  # $1 = organization
  echo "Creating organization '$1' ..."
  $CURL -H 'Content-Type: application/json' \
   -H "Authorization: ${CONCORD_API_TOKEN}" \
   -d "{ \"name\": \"$1\" }" \
   ${CONCORD_URL}/api/v1/org
}