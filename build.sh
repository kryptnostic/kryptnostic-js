#!/bin/bash

rm -rfv build/*;
r.js -o build.js out=build/soteria.js optimize=none
r.js -o build.js out=build/soteria.min.js optimize=uglify
