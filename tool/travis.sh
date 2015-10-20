#!/bin/bash

# Fast fail the script on failures.
set -e

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings \
  lib/rxdart.dart \
  test/all_tests.dart

# Run the tests.
pub run test -p content-shell test