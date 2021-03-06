#!/usr/bin/env sh

set -e

source script/docker-functions

rm -rf tmp
docker_build_bundle_base
docker run --rm -v ${PWD}/tmp:/tmp/bundle_update pact_broker_bundle_base:latest sh -c "bundle update && cp Gemfile.lock /tmp/bundle_update"
mv tmp/Gemfile.lock pact_broker/

unset PACT_BROKER_DATABASE_HOST
unset PACT_BROKER_DATABASE_USERNAME
unset PACT_BROKER_DATABASE_PASSWORD
PACT_BROKER_DATABASE_NAME=pact_broker.sqlite PACT_BROKER_DATABASE_ADAPTER=sqlite script/test.sh
PACT_BROKER_DATABASE_NAME=pact_broker.sqlite PACT_BROKER_DATABASE_ADAPTER=sqlite script/test_basic_auth.sh
git add pact_broker
git commit -m "feat(gems): update pact_broker gem to version $(get_pact_broker_version)"
git push
