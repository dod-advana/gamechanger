#!/usr/bin/env/bash
_script_dir="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
_repo_dir="$(cd -- "${_script_dir}/../" &> /dev/null && pwd)"

DEPLOY_BUILD_DIR="${_repo_dir}/deploy/build"
DEPLOY_VAR_DIR="${_repo_dir}/deploy/var"

unset _script_dir
unset _repo_dir

declare -a REPO_NAMES=(\
  gamechanger-web \
  gamechanger-data \
  gamechanger-ml \
  gamechanger-neo4j-plugin \
  gamechanger-crawlers \
)

declare -A REPO_URL_MAP=(\
  [gamechanger-web]="https://github.com/dod-advana/gamechanger-web" \
  [gamechanger-data]="https://github.com/dod-advana/gamechanger-data.git" \
  [gamechanger-ml]="https://github.com/dod-advana/gamechanger-ml.git" \
  [gamechanger-neo4j-plugin]="https://github.com/dod-advana/gamechanger-neo4j-plugin.git" \
  [gamechanger-crawlers]="https://github.com/dod-advana/gamechanger-crawlers.git" \
)

declare -A REPO_TAG_MAP=(\
  [gamechanger-web]="task/UOT-117914" \
  [gamechanger-data]="task/UOT-117914" \
  [gamechanger-ml]="task/UOT-117914" \
  [gamechanger-neo4j-plugin]="main" \
  [gamechanger-crawlers]="dev" \
)

declare -A REPO_DIR_MAP=(\
  [gamechanger-web]="${DEPLOY_BUILD_DIR}/gamechanger-web" \
  [gamechanger-data]="${DEPLOY_BUILD_DIR}/gamechanger-data" \
  [gamechanger-ml]="${DEPLOY_BUILD_DIR}/gamechanger-ml" \
  [gamechanger-neo4j-plugin]="${DEPLOY_BUILD_DIR}/gamechanger-neo4j-plugin" \
  [gamechanger-crawlers]="${DEPLOY_BUILD_DIR}/gamechanger-crawlers" \
)

declare -A SERVICE_VAR_DIR_MAP=(\
  [data-pipelines]="${DEPLOY_VAR_DIR}/data-pipelines" \
  [gamechanger-ml]="${DEPLOY_VAR_DIR}/gamechanger-ml" \
  [redis]="${DEPLOY_VAR_DIR}/redis" \
  [neo4j]="${DEPLOY_VAR_DIR}/neo4j" \
  [elasticsearch]="${DEPLOY_VAR_DIR}/elasticsearch" \
  [s3-server]="${DEPLOY_VAR_DIR}/s3-server" \
  [postgres]="${DEPLOY_VAR_DIR}/postgres" \
)