# В качестве родительского образа будем использовать готовый образ:
FROM nginx:1.16.0

# Все последующие команды будут выполняться от имени root-пользователя:
USER root

# Устанавливаем программное обеспечение, необходимое для корректной работы приложения:
ENV BUILD_PACKAGES curl
RUN apt-get update -qq && apt-get install -y $BUILD_PACKAGES

# Удалим дефолтную welcome страницу nginx
RUN rm /usr/share/nginx/html/*

# Скопируем custom и default nginx конфигурации
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/default.conf /etc/nginx/conf.d/default.conf

RUN touch /var/run/nginx.pid && \
    chown -R www-data:www-data /var/run/nginx.pid && \
    chown -R www-data:www-data /var/cache/nginx && \
    chown -R www-data:www-data /etc/nginx && \
    chown -R www-data:www-data /var/log

# Все последующие команды будут выполняться от имени www-data пользователя:
USER www-data

# Команды, которые будут выполнены только перед запуском контейнера:
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["./docker-entrypoint.sh"]

# Стандартная команда по запуску образа:
CMD ["nginx", "-g", "daemon off;"]
