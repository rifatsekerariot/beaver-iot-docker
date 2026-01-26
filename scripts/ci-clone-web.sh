#!/bin/sh
# Clone beaver-iot-web for CI. Run from workspace root.
# DEST=beaver-iot-web (sibling of beaver-iot-docker) for local layout; else build-docker/beaver-iot-web.
# Trigger: 2026-01-26 report DEVICE_ID-based entity fetch.

set -e
WEB_REPO="${WEB_GIT_REPO_URL:-https://github.com/rifatsekerariot/beaver-iot-web.git}"
WEB_BRANCH="${WEB_GIT_BRANCH:-main}"
DEST="${CI_CLONE_WEB_DEST:-build-docker/beaver-iot-web}"

# Remove branch prefix if present (origin/main -> main)
BRANCH_NAME=$(echo "$WEB_BRANCH" | sed 's/^origin\///')
echo "Cloning beaver-iot-web from $WEB_REPO, branch: $BRANCH_NAME"

rm -rf "$DEST"
git clone --depth 1 -b "$BRANCH_NAME" "$WEB_REPO" "$DEST"
echo "Cloned beaver-iot-web into $DEST (branch: $BRANCH_NAME)"

# Verify the latest commit
cd "$DEST"
LATEST_COMMIT=$(git rev-parse HEAD)
LATEST_COMMIT_MSG=$(git log -1 --pretty=format:"%h %s")
echo "Latest commit in $BRANCH_NAME: $LATEST_COMMIT"
echo "Latest commit message: $LATEST_COMMIT_MSG"
cd - > /dev/null
