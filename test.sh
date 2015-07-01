#!/bin/bash

./build.sh --fast

cd js
karma start --single-run true
cd -
