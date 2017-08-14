#!/usr/bin/env bash
set -e # Exit with non-zero exit code if anything fails

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

ENCRYPTION_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTION_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTION_KEY=${!ENCRYPTION_KEY_VAR}
ENCRYPTION_IV=${!ENCRYPTION_IV_VAR}

function doCompile {
    bundle exec middleman build
}

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Not deploying pull request; just doing a build."
    doCompile
    exit 0
fi

echo -e "\nRunning Travis Deployment"
echo "Setting up Git Access"

REPO=$(git config remote.origin.url)
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
SHA=`git rev-parse --verify HEAD`

openssl aes-256-cbc -K $ENCRYPTION_KEY -iv $ENCRYPTION_IV -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key

# Add the SSH key so it's used on git commands
eval `ssh-agent -s`
ssh-add deploy_key

git clone $REPO build
cd build
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
cd ..

rm -rf build/**/* || exit 0

doCompile

echo "Creating Git Commit"
cd build

git config user.name ${GH_COMMIT_AUTHOR}
git config user.email ${GH_COMMIT_EMAIL}

if git diff --quiet; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

git add -A .
git commit -m "Deploy to GitHub Pages: ${SHA}"

echo "Deploying to GitHub"
git push $SSH_REPO $TARGET_BRANCH

