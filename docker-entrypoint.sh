#!/bin/bash
# Interpreter identifier

# Exit on fail
set -e

bundle exec rake db:create
bundle exec rake db:migrate

exec "$@"
