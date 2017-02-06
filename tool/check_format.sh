#!/bin/sh

# Determine which files have been modified and should be run through the formatter
dart_files=$(git diff --cached --name-only --diff-filter=ACM | grep '.dart$')
[ -z "$dart_files" ] && exit 0

# Run dartfmt to check if the modified files are properly formatted.
unformatted=$(dartfmt -n ${dart_files})
[ -z "$unformatted" ] && exit 0

# If the files are not properly formatted. Print message and fail.
echo >&2 "The following dart files must be formatted with dartfmt. Please run: dartfmt -w ./**/*.dart from the root of the git repository."
for fn in ${unformatted}; do
  echo >&2 "./$fn"
done

exit 1
