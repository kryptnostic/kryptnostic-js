#!/bin/bash

set -e;

# lint
# ====
echo "linting files...";
find js -name *.coffee | xargs ./node_modules/coffeelint/bin/coffeelint;

# r.js build
# ==========
echo "building soteria.js...";
./build.sh --fast;

# karma tests
# ===========
echo "running unit tests...";
cd js;
karma start --single-run true;
cd -;
