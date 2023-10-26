#!/bin/bash

set -e
set -o pipefail

SHA="$1"
TOKEN="$2"
DOMAIN="$3"
CONFIG_PATH="$4"

SUPERBLOCKS_BOT_NAME="superblocks-app[bot]"

if [ -z "$REPO_DIR" ]; then
  REPO_DIR="$(pwd)"
else
  cd "$REPO_DIR"
fi

git config --global --add safe.directory "$REPO_DIR"

# Get the name of the actor who made the last commit
actor_name=$(git show -s --format='%an' "$SHA")
if [ "$actor_name" != "$SUPERBLOCKS_BOT_NAME" ]; then
    printf "\nCommit was not made by Superblocks. Skipping components pull...\n"
    exit 0
fi

# Get the list of changed files in the last commit
changed_files=$(git diff "${SHA}"^ --name-only)

if [ -n "$changed_files" ]; then
    superblocks --version

    # Login to Superblocks
    printf "\nLogging in to Superblocks...\n"
    superblocks config set domain "$DOMAIN"
    superblocks login -t "$TOKEN"
else
    echo "No files changed since the last commit. Skipping pull..."
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
              -m "[superblocks ci] This commit was automatically generated by a Superblocks GitHub Action."
            git push origin HEAD
        else
            printf "\nNo components diff detected. Skipping commit...\n"
        fi
    fi
}

# Check if any Superblocks applications have changed
jq -r '.resources[] | select(.resourceType == "APPLICATION") | .location' "$CONFIG_PATH" | while read -r location; do
    printf "\nChecking %s for changes...\n" "$location"
    pull_and_commit "$location"
done
