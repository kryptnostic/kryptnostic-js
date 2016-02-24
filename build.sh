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

r_js=`find . -name 'r.js' | tail -n 1`
echo "using r.js at $r_js"
if [[ $@ != **--release** ]]; then
  echo; echo 'running full build -> kryptnostic.js';
  $r_js -o build.js out=dist/kryptnostic.js optimize=none;
  echo; echo 'running webpack build -> kryptnostic.umd.js';
  ./node_modules/webpack/bin/webpack.js
else
  echo; echo 'running full build -> kryptnostic.js';
  $r_js -o build.js out=dist/kryptnostic.js optimize=none;
  echo; echo 'running uglified build -> kryptnostic.min.js';
  $r_js -o build.js out=dist/kryptnostic.min.js optimize=uglify;
  echo; echo 'running webpack build -> kryptnostic.umd.js';
  ./node_modules/webpack/bin/webpack.js
fi

echo; echo "copying kryptnostic client";
cp bower_components/krypto-js/KryptnosticClient.js dist/KryptnosticClient.js;

echo; echo "copying web workers";
cp js/src/workers/RSAKeysGenerationWorker.js dist/ ;
cp js/src/workers/FHEKeysGenerationWorker.js dist/ ;

echo; echo "DIST BUILD SUCCESSFUL!";
echo ":)";
echo;
