
.PHONY: android build publish publish-web publish-android icons insert-revision-count

run: insert-revision-count
	npm run dev -- --open

install:
	npm install
	npm install @capacitor/android
	npm install @capacitor/ios
	@echo npx cap add android
	@echo npx cap add ios


insert-revision-count:
	@echo "Inserting Git revision count into settings/+page.svelte"
	@VERSION="1.0"; \
		REVISION_COUNT=`git rev-list --all --count` ; \
		sed -i "s/'Revision:.*'/'Revision: $$VERSION.$$REVISION_COUNT'/g" "src/routes/(marketing)/settings/+page.svelte"



build: insert-revision-count
	npm run build

publish : publish-web publish-android

publish-web :
	ssh towntag "cd towntag/app && git reset --hard && git pull && npm run build" > /tmp/towntag-build.log 2>&1 &
	#rsync -Pr build/ towntag.app:/var/www/towntag.app/
	@echo surge build towntag.surge.sh

android: build
	@echo npx cap open android
	npx cap sync
	@(cd android ; ./gradlew :app:assembleDebug)

publish-android : android
	rsync -Pr android/app/build/outputs/apk/debug/app-debug.apk towntag:/var/www/towntag.lol/towntag.apk

icons:
	@echo "Create assets/logo.png and assets/logo-dark.png"
	@mkdir -p www
	npx cap sync
	npx capacitor-assets generate

quick: build
	surge build




