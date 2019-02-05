#!/bin/bash -exo pipefail

CIRCLE_COMPARE_URL=$(cat CIRCLE_COMPARE_URL.txt)
COMMIT_RANGE=$(echo $CIRCLE_COMPARE_URL | sed 's:^.*/compare/::g')
echo "Commit range: $COMMIT_RANGE"
for ORB in src/*/; do
  orbname=$(basename $ORB)
  if [[ $(git diff $COMMIT_RANGE --name-status | grep "$orbname") ]]; then
    (ls ${ORB}orb.yml && echo "orb.yml found, attempting to publish...") || echo "No orb.yml file was found - the next line is expected to fail."
    circleci orb publish ${ORB}orb.yml circleci/${orbname}@dev:${CIRCLE_BRANCH}-${CIRCLE_SHA1} --token $CIRCLECI_API_TOKEN
  else
    echo "${orbname} not modified; no need to promote"
  fi
  echo "------------------------------------------------------"
done
