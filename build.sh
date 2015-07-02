#!/bin/bash

# fail if anything goes wrong
set -e

echo "running commit hooks..."
./commit-hooks.rb

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
  r.js -o build.js out=build/soteria.js optimize=none
else
  echo "running minified build..."
  r.js -o build.js out=build/soteria.min.js optimize=uglify
fi
