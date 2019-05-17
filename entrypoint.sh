#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "GITHUB_TOKEN is not set."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_NAME" ]]; then
  echo "GITHUB_REPOSITORY is not set."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "GITHUB_EVENT_PATH is not set."
  exit 1
fi

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
state=$(jq --raw-output .review.state "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

# This part borrowed from https://github.com/pullreminders/label-when-approved-action/blob/master/entrypoint.sh
is_review_approved() {
# https://developer.github.com/v3/pulls/reviews/#list-reviews-on-a-pull-request
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
  reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

  approvals=0

  for r in $reviews; do
    review="$(echo "$r" | base64 --decode)"
    rState=$(echo "$review" | jq --raw-output '.state')

    if [[ "$rState" == "APPROVED" ]]; then
      approvals=$((approvals+1))
    fi

    echo "${approvals}/${APPROVALS} approvals"

    if [[ "$approvals" == "$APPROVALS" ]]; then
      echo "${APPROVALS} reached."
      return 0
    fi
  done

  return 1
}

is_not_terraform() {
# https://developer.github.com/v3/pulls/#list-pull-requests-files
# N.B.: This endpoint can return a maximum of 300 modified files. It is unlikely that we will exceed this.
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}/files")
  files=$(echo "$body" | jq --raw-output '.[] | {filename: .filename}')

  for file in $files; do
    if [[ "$file" == *".tf"* ]]; then
      echo "This commit appears to contain .tf files!"
      return 1
    fi
  done

  return 0
}

if [[ "$action" == "submitted" ]] && [[ "$state" == "approved" ]]; then
  if is_review_approved ; then
    if is_not_terraform ; then
      echo "This looks OK to me."
    fi
  fi
else
  echo "Ignoring event ${action}/${state}"
  exit 78
fi
