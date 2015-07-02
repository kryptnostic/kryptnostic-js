#!/bin/bash

./pre-build.rb

rm -rfv build/*;

if [[ $@ != **--minify** ]]; then
  echo "running development build (no minification)."
  r.js -o build.js out=build/soteria.js optimize=none
else
  echo "running minified build. this will be slower."
  r.js -o build.js out=build/soteria.min.js optimize=uglify
fi