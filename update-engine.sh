#!/bin/bash

#
# Author: rbuckheit
# Updates kryptnostic-engine.

set -e;

# update krypto
# =============
cd ../krypto;
git pull;
cd -;

# copy module
# ===========
mkdir -p js/lib;
cp ../krypto/krypto-lib/src/main/js/KryptnosticClient.js js/lib/KryptnosticClient.js;

