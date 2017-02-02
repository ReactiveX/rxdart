# Ensure the source is formatted
$(dirname -- "$0")/ensure_dartfmt.sh

# Fast fail the script on failures.
set -e

# Run all tests.
pub run test -p content-shell test/all_tests.html

# Install dart_coveralls; gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all_tests.dart
fi
