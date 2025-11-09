#!/bin/bash
set -e

file="$1"

if [[ -z "$file" ]]; then
  echo "Error: No file provided"
  echo "Usage: ruby_profile.sh <file>"
  exit 1
fi

dir=$(dirname "$file")
while [[ "$dir" != "." && "$dir" != "/" ]]; do
  if [[ -f "$dir/Gemfile" ]]; then
    project_root="$dir"
    break
  fi
  dir=$(dirname "$dir")
done

if [[ -z "$project_root" ]]; then
  echo "Error: Could not find Gemfile for $file"
  exit 1
fi

cd "$project_root"

rel_file="${file#$project_root/}"

if [[ "$(basename "$file")" == *_test.rb ]]; then
  ruby_cmd="ruby -I test"
else
  ruby_cmd="ruby"
fi

rm -f /tmp/profile.json
PROFILING=true vernier run --output=/tmp/profile.json -- bundle exec $ruby_cmd "$rel_file"

if [[ "$CURSOR_AGENT" == "1" ]]; then
  LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 vernier view --top 100 -- /tmp/profile.json
else
  profile-viewer /tmp/profile.json
fi

