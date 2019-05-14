#!/usr/bin/env bash

# Завершаем выполнение скрипта, в случае ошибки:
set -e

APP_NAME=${CUSTOM_APP_NAME:="server_app"} # имя контейнера с запущенным приложением Spree
APP_PORT=${CUSTOM_APP_PORT:="3000"} # порт, по которому доступно приложение Spree
APP_VHOST=${CUSTOM_APP_VHOST:="$(curl http://169.254.169.254/latest/meta-data/public-hostname)"} # Хост виртуального сервера на AWS по умолчанию ссылается на общедоступный DNS-адрес AWS EC2, "подтянув" эту информацию из метаданных EC2. Это позволяет нам динамически настраивать Nginx во время запуска контейнера

DEFAULT_CONFIG_PATH="/etc/nginx/conf.d/default.conf"

# Заменяем все инстансы плейсхолдеров на значения, указанные выше: 
sed -i "s+APP_NAME+${APP_NAME}+g"     "${DEFAULT_CONFIG_PATH}"
sed -i "s+APP_PORT+${APP_PORT}+g"     "${DEFAULT_CONFIG_PATH}"
sed -i "s+APP_VHOST+${APP_VHOST}+g"   "${DEFAULT_CONFIG_PATH}"
sed -i "s+STATIC_PATH+${STATIC_PATH}+g"   "${DEFAULT_CONFIG_PATH}"

# Выполнение CMD из Dockerfile с передачей всех аргументов
exec "$@"
