#!/usr/bin/env bash
CURL="curl -L -sS -o /dev/null "

concord_project() {
  # $1 = projectname
  echo "Creating project in organization $1..."
  $CURL -H 'Content-Type: application/json' \
   -H "Authorization: ${CONCORD_API_TOKEN}" \
   -d "{ \"name\": \"$1\", \"acceptsRawPayload\": true, \"rawPayloadMode\" : \"EVERYONE\" }" \
   http://${CONCORD_HOST_PORT}/api/v1/org/${ORGANIZATION}/project
}

concord_organization() {
  # $1 = organization
  echo "Creating organization '$1' ..."
  $CURL -H 'Content-Type: application/json' \
   -H "Authorization: ${CONCORD_API_TOKEN}" \
   -d "{ \"name\": \"$1\" }" \
   http://${CONCORD_HOST_PORT}/api/v1/org
}