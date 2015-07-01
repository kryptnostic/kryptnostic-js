#!/bin/bash
if [[ $@ != **--fast** ]]; then
  echo "running full build. please use the \"--fast\" option to do a partial build."
fi

./pre-build.rb

rm -rfv build/*;
r.js -o build.js out=build/soteria.js optimize=none

if [[ $@ != **--fast** ]]; then
  r.js -o build.js out=build/soteria.min.js optimize=uglify
fi
