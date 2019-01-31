#!/usr/bin/env bash
if [ $CIRCLE_BRANCH == $SOURCE_BRANCH ]; then
	echo "step 1"
	git config --global user.email $GH_EMAIL
	git config --global user.name $GH_NAME

	git clone $CIRCLE_REPOSITORY_URL out

	cd out
	git checkout $TARGET_BRANCH || git checkout --orphan $TARGET_BRANCH
	git rm -rf .
	cd ../repo

	npm run build

	cd ..

	mv ./repo/index.html ./out/index.html
	mv ./repo/index.js ./out/index.js
	mv ./repo/index.map ./out/index.map
	mv ./repo/worker.js ./out/worker.js
	mv ./repo/worker.map ./out/worker.map
	mv ./repo/manifest.json ./out/manifest.json
	mv ./repo/CNAME ./out/CNAME

	mkdir -p out/.circleci && cp -a repo/.circleci/. out/.circleci/.
	cd out

	git add -A
	git commit -m "Automated deployment to GitHub Pages: ${CIRCLE_SHA1}" --allow-empty

	git push origin $TARGET_BRANCH
fi
