#!/bin/bash

#
# Builds the distribution file soteria.js.
# Author: rbuckheit
#

set -e;

echo "compiling libraries..."
if [ -e bower_components/forge/js/forge.min.js ];
then
  echo "forge.min.js is already compiled. skipping!"
else
  echo "compiling forge.min.js"
  cd bower_components/forge;
  npm install;
  npm run minify;
  cd ../../;
fi

echo ""
echo "compiling r.js exports..."
./compile-exports.rb

echo ""
echo "cleaning build artifacts..."
rm -rfv build/*;

echo ""
if [[ $@ != **--minify** ]]; then
  echo "running development build (no minification)..."
  ./node_modules/requirejs/bin/r.js -o build.js out=build/soteria.js optimize=none
else
  echo "running minified build..."
  ./node_modules/requirejs/bin/r.js -o build.js out=build/soteria.min.js optimize=uglify
fi
