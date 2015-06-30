#!/bin/bash

./build.sh

cd js
karma start --single-run true
cd -
