#!/bin/bash

#
# Runs all build checks which should be tested as part of CI build.
# Author: rbuckheit
#

set -e;

# lint
# ====
echo "linting files...";
find js -name *.coffee | xargs ./node_modules/coffeelint/bin/coffeelint;

# commit hooks
# ============
echo "running commit hooks..."
./commit-hooks.rb;

# r.js build
# ==========
echo "building soteria.js...";
./build.sh;

# karma tests
# ===========
echo "running unit tests...";
cd js;
../node_modules/karma-cli/bin/karma start --single-run true;
cd -;

# output
# ======
echo "BUILD SUCCESSFUL";
