#!/bin/bash

#
# Builds the distribution file kryptnostic.js.
# Pass the --release flag to do a full release.
# Author: rbuckheit
#

set -e;

# compile forge
echo 'compiling libraries...';
if [[ -e bower_components/forge/js/forge.min.js && $@ != **--release** ]]; then
  echo 'forge.min.js is already compiled, skipping ...';
else
  echo 'compiling forge.min.js...';
  cd bower_components/forge;
  npm install;
  npm run minify;
  cd ../../;
fi

# generate kryptnostic.coffee export file
echo; echo 'compiling r.js exports...';
./compile-exports.rb;

# clean build directory
echo; echo 'cleaning build artifacts...';
rm -rfv dist/*;

if [[ $@ != **--release** ]]; then
  echo; echo 'running full build -> kryptnostic.js';
  ./node_modules/requirejs/bin/r.js -o build.js out=dist/kryptnostic.js optimize=none;
else
  echo; echo 'running full build -> kryptnostic.js';
  ./node_modules/requirejs/bin/r.js -o build.js out=dist/kryptnostic.js optimize=none;
  echo; echo 'running uglified build -> kryptnostic.min.js';
  ./node_modules/requirejs/bin/r.js -o build.js out=dist/kryptnostic.min.js optimize=uglify;
fi

echo; echo "copying kryptnostic client";
cp bower_components/kryptnostic-client/index.js dist/KryptnosticClient.js;

echo; echo 'compiling demo.coffee...';
./node_modules/coffee-script/bin/coffee -c demo/demo.coffee;

echo; echo "DIST BUILD SUCCESSFUL!";
echo ":)";
echo;

