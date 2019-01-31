#!/usr/bin/env bash
echo "step 1 [SET GIT USER]"
git config --global user.email "bot@tracktask.io"
git config --global user.name "Bot"

echo "step 2 [CLONE REPO]"
git clone $CIRCLE_REPOSITORY_URL out

cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
git rm -rf .

cd ../

npm run build

ls -la dist

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"

cp -v ./dist/* ./out
cp ./CNAME ./out

ls -la out

# mkdir -p out/.circleci && cp -a repo/.circleci/. out/.circleci/.
# cd out

# git add -A
# git commit -m "Automated deployment to GitHub Pages: ${CIRCLE_SHA1}" --allow-empty

# git push origin $TARGET_BRANCH
