#!/bin/bash

# Fast fail the script on failures.
set -e

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings \
  lib/rxdart.dart \
  test/all_tests.html

# Run the tests.
dart -c test/all_tests.html
