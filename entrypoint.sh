#!/bin/bash

set -e
set -o pipefail

COMMIT_SHA="${COMMIT_SHA:-HEAD}"
SUPERBLOCKS_DOMAIN="${SUPERBLOCKS_DOMAIN:-app.superblocks.com}"
SUPERBLOCKS_CONFIG_PATH="${SUPERBLOCKS_CONFIG_PATH:-.superblocks/superblocks.json}"
SUPERBLOCKS_AUTHOR_NAME="${SUPERBLOCKS_AUTHOR_NAME:-superblocks-app[bot]}"
SUPERBLOCKS_AUTHOR_EMAIL="${SUPERBLOCKS_AUTHOR_EMAIL:-142439023+superblocks-app[bot]@users.noreply.github.com}"
SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER="${SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER:-[superblocks ci]}"

# Ensure that a Superblocks token is provided
if [ -z "$SUPERBLOCKS_TOKEN" ]; then
  printf "\nThe 'SUPERBLOCKS_TOKEN' environment variable is unset or empty. Exiting...\n"
  exit 1
fi

if [ -z "$REPO_DIR" ]; then
  REPO_DIR="$(pwd)"
else
  cd "$REPO_DIR"
fi

git config --global --add safe.directory "$REPO_DIR"

# Get the actor name and commit message the last commit
actor_name=$(git show -s --format='%an' "$COMMIT_SHA")
commit_message=$(git show -s --format='%B' "$COMMIT_SHA")

# Skip pull if the commit was not made by Superblocks. To support multiple Git providers, we also
# check for the commit message identifier used to identify Superblocks commits.
if [ "$actor_name" != "$SUPERBLOCKS_AUTHOR_NAME" ] && ! echo "$commit_message" | grep -qF "$SUPERBLOCKS_COMMIT_MESSAGE_IDENTIFIER" ; then
    printf "\nCommit was not made by Superblocks. Skipping components pull...\n"
    exit 0
fi

# Get the list of changed files in the last commit
changed_files=$(git diff "${COMMIT_SHA}"^ --name-only)

if [ -n "$changed_files" ]; then
    superblocks --version

    # Login to Superblocks
    printf "\nLogging in to Superblocks...\n"
    superblocks config set domain "$SUPERBLOCKS_DOMAIN"
    superblocks login -t "$SUPERBLOCKS_TOKEN"
else
    printf "\nNo files changed since the last commit. Skipping pull...\n"
    exit 0
fi

# Function to pull custom Components for any changed Superblocks application
pull_and_commit() {
    local location="$1"
    if echo "$changed_files" | grep -q "^$location/"; then
        printf "\nChange detected. Pulling components for latest commit...\n"
        superblocks pull "$location" -m "most-recent-commit"

        # Check if any changes were made to the components subdir based on the pull
        app_components_dir="${location}/components"
        if [ -n "$(git diff --name-only -- "$app_components_dir")" ]; then
            printf "\nComponents diff detected between local and remote components. Committing changes...\n"

            git config user.name "$SUPERBLOCKS_AUTHOR_NAME"
            git config user.email "$SUPERBLOCKS_AUTHOR_EMAIL"

            git add "$app_components_dir"
            git commit -m "Pull components source code for '$location'" \
              -m "[superblocks ci] This commit was automatically generated by Superblocks."
            git push origin HEAD
        else
            printf "\nNo components diff detected. Skipping commit...\n"
        fi
    else
        printf "\nNo change detected. Skipping pull...\n"
    fi
}

# Check if any Superblocks applications have changed
jq -r '.resources[] | select(.resourceType == "APPLICATION") | .location' "$SUPERBLOCKS_CONFIG_PATH" | while read -r location; do
    printf "\nChecking %s for changes...\n" "$location"
    pull_and_commit "$location"
done

printf "\nChecking complete. Exiting...\n"
