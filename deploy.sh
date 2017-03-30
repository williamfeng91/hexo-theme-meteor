#!/bin/sh

vcs_type=$1
username=$2
project=$3
branch=$4

if [ -z "$vcs_type" ] || \
    [ -z "$username" ] || \
    [ -z "$project" ] || \
    [ -z "$branch" ]; then
  echo "Need to pass FOUR arguments to deploy:"
  echo "  $0 <vcs_type> <username> <project> <branch>"
  echo
  echo "  Example: $0 github meteor docs master"
  exit 1
fi

description="${vcs_type}:${username}/${project}@${branch}"

api_var=$(\
  echo "DEPLOY_API_KEY_${vcs_type}_${username}_${project}_${branch}" | \
  tr '[a-z]' '[A-Z]' \
)

api_key="$(eval "echo \$${api_var}")"

if [ -z "$api_key" ]; then
  echo "ERROR: No API key found for ${description}"
  exit 1
fi

base_url="https://circleci.com/api/v1.1/project/"
path="${vcs_type}/${username}/${project}/tree/${branch}?circle-token=${api_key}"

full_url="${base_url}${path}"

echo "Triggering ${description} Build"
curl --request POST \
  --silent \
  --fail \
  --url "${full_url}" \
  --header 'cache-control: no-cache' > \
  /dev/null 2>&1 # NO OUTPUT just in case it leaks the token.

if [ $? -eq 0 ]; then
  echo "  Successful!"
  exit 0
else
  echo "  FAILED!!!"
  exit 1
fi