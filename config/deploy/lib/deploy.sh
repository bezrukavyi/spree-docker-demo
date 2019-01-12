#!/bin/bash

# Required variables:
# - region # ECR Region
# - aws-access-key # AWS Access Id
# - aws-secret-key # AWS Secret Key
# - service # Service's name
# - repo # Service's repository
# - cluster # Service's cluster
# - name # Application's container name

set -e

deploy() {
  while [[ $# -gt 0 ]]
  do
  key="$1"

  case $key in
      --region)
      REGION="$2"
      shift
      shift
      ;;
      --aws-access-key)
      AWS_ACCESS_KEY_ID="$2"
      shift
      shift
      ;;
      --aws-secret-key)
      AWS_SECRET_ACCESS_KEY="$2"
      shift
      shift
      ;;
      --repo)
      REPO="$2"
      shift
      shift
      ;;
      --cluster)
      CLUSTER="$2"
      shift
      shift
      ;;
      --service)
      SERVICE="$2"
      shift
      shift
      ;;
      --name)
      APP_NAME="$2"
      shift
      shift
      ;;
      --skip-build)
      SKIP_BUILD="$2"
      shift
      shift
      ;;
      *)
      echo "Unknown option $1\n"
      shift
      shift
  esac
  done

  VERSION=${CIRCLE_BRANCH:="$(git rev-parse --abbrev-ref HEAD)"}
  BUILD_APP=$APP_NAME:$VERSION
  BUILD_REPO=$REPO:$VERSION

  echo "📦  Install dependencies"
  dependencies_setup

  echo "🐳  Build docker image $BUILD_APP"
  push_to_docker

  echo "🚀  Deploy $BUILD_APP to $CLUSTER:$SERVICE"
  ecs_deploy

  echo '✅  Deploy successfully finished'
}

# Устанавливаем пакеты, необходимые для деплоя
dependencies_setup () {
  python3 -m venv venv
  . venv/bin/activate
  pip install -r config/deploy/dependencies.txt
}

# Пушим текущую версию в репозиторий
push_to_docker() {
  if [ -n "$SKIP_BUILD" ]; then echo 'Skip build'
  else
    $(aws ecr get-login --region $REGION --no-include-email)

    docker build --cache-from=$BUILD_APP -t $BUILD_APP .
    docker tag $BUILD_APP $BUILD_REPO
    docker push $BUILD_REPO
  fi
}

# Деплоим сервис
ecs_deploy() {
  ecs deploy $CLUSTER $SERVICE --region $REGION
}

exec "$@"
