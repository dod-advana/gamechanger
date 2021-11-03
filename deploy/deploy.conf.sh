#!/usr/bin/env/bash
_script_dir="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
_repo_dir="$(cd -- "${_script_dir}/../" &> /dev/null && pwd)"

DEPLOY_SRC_DIR="${_repo_dir}/deploy/src"

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
  [gamechanger-web]="${DEPLOY_SRC_DIR}/gamechanger-web" \
  [gamechanger-data]="${DEPLOY_SRC_DIR}/gamechanger-data" \
  [gamechanger-ml]="${DEPLOY_SRC_DIR}/gamechanger-ml" \
  [gamechanger-neo4j-plugin]="${DEPLOY_SRC_DIR}/gamechanger-neo4j-plugin" \
  [gamechanger-crawlers]="${DEPLOY_SRC_DIR}/gamechanger-crawlers" \
)