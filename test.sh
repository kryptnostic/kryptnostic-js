#!/bin/bash

#
# runs all build checks which should be tested as part of CI build.
#

set -e;

# lint
# ====
echo; echo "linting files...";
find js -name *.coffee | xargs ./node_modules/coffeelint/bin/coffeelint;
find demo -name *.coffee | xargs ./node_modules/coffeelint/bin/coffeelint;

# commit hooks
# ============
echo; echo "running commit hooks..."
./commit-hooks.rb;

# unused imports
# ==============
echo; echo "checking for unused imports..."
./check-unused-imports.rb;

# r.js build
# ==========
echo; echo "building kryptnostic.js...";
./build.sh;

# karma unit tests
# ===========
echo; echo "running unit tests...";
node_modules/karma-cli/bin/karma start js/karma.conf.js --single-run true;

# karma browser tests
# ===================
echo; echo "running browser-only tests...";
echo; echo "TEMPORARY - inlining KryptnosticClient.js into KarmaJS context.html...";
cp karmajs-kcjs-context.html node_modules/karma/static/context.html;

echo;
node_modules/karma-cli/bin/karma start js/karma-browser-only.conf.js --single-run true;

# output
# ======
echo "ALL TESTS PASSED!";
echo ":)";
echo;
