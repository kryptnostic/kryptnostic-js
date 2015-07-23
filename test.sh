#!/bin/bash

#
# Runs all build checks which should be tested as part of CI build.
# Author: rbuckheit
#

set -e;

mode=$1

echo "running with mode $mode";

# lint
# ====
echo; echo "linting files...";
find js -name *.coffee | xargs ./node_modules/coffeelint/bin/coffeelint;

# commit hooks
# ============
echo; echo "running commit hooks..."
./commit-hooks.rb;

# unused import checking
echo; echo "checking for unused imports..."
./check-unused-imports.rb;

# r.js build
# ==========
echo; echo "building kryptnostic.js...";
./build.sh;

# karma tests
# ===========
echo; echo "running unit tests...";
cd js;
if [[ $mode =~ "--full" ]]; then
  echo "running in browsers"
  ../node_modules/karma-cli/bin/karma start --single-run true --browsers Chrome,Safari,PhantomJS,Firefox
else
  ../node_modules/karma-cli/bin/karma start --single-run true;
fi
cd -;

# output
# ======
echo "BUILD SUCCESSFUL";
