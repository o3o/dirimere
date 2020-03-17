#!/bin/sh +v
NEW_VER=$@
sed -i -r "s/VERSION\s*=\s*\"[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+\.[0-9]+)?\"/VERSION = \"${NEW_VER}\"/g" src/app.d
git commit -a -m "Bumped version to ${NEW_VER}"
