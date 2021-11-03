#!/usr/bin/env bash
set -o nounset
set -o errexit

SCRIPT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/../" &> /dev/null && pwd)"
DEPLOY_CONF="${SCRIPT_DIR}/deploy.conf.sh"

source "$DEPLOY_CONF"

function main() (
  docker-compose \
    --project-directory "${REPO_DIR}/deploy" \
    --file "${REPO_DIR}/deploy/docker-compose.yaml" \
    build
)

main