#!/usr/bin/env/bash

DEPLOY_SRC_DIR="${REPO_DIR}/deploy/src"

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
  [gamechanger-web]="dev" \
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