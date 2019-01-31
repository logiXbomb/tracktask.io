#!/usr/bin/env bash
echo "step 1 [SET GIT USER]"
git config --global user.email "bot@tracktask.io"
git config --global user.name "Bot"

echo "step 2 [CLONE REPO]"
git clone $CIRCLE_REPOSITORY_URL out

echo "step 3 [BUNDLE SOURCE]"
cd out
git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
git rm -rf .

cd ../

npm run build

echo "step 3 [COPY FILES]"

cp -v ./dist/* ./out
cp ./CNAME ./out

mkdir -p out/.circleci && cp -a repo/.circleci/. out/.circleci/.

echo "step 4 [DEPLOY CHANGES]"


cd out

git add -A
git commit -m "Automated deployment to GitHub Pages: ${CIRCLE_SHA1}" --allow-empty

git push origin $TARGET_BRANCH

