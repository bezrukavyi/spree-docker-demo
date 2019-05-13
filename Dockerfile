# Layer 0. Качаем образ Debian OS с установленным ruby версии 2.5 и менеджером для управления gem'ами bundle из DockerHub. Используем его в качестве родительского образа.
FROM ruby:2.5.1-slim

# Layer 1. Задаем пользователя, от чьего имени будут выполняться последующие команды RUN, ENTRYPOINT, CMD и т.д.
USER root

# Layer 2. Обновляем и устанавливаем нужное для Web сервера ПО
RUN apt-get update -qq && apt-get install -y \
  build-essential libpq-dev libxml2-dev libxslt1-dev nodejs imagemagick apt-transport-https curl nano

# Layer 3. Создаем переменные окружения которые буду дальше использовать в Dockerfile
ENV APP_USER app
ENV APP_USER_HOME /home/$APP_USER
ENV APP_HOME /home/www/spreedemo

# Layer 4. Поскольку по умолчанию Docker запускаем контейнер от имени root пользователя, то настоятельно рекомендуется создать отдельного пользователя c определенными UID и GID и запустить процесс от имени этого пользователя.
RUN useradd -m -d $APP_USER_HOME $APP_USER

# Layer 5. Даем root пользователем пользователю app права owner'а на необходимые директории
RUN mkdir /var/www && \
  chown -R $APP_USER:$APP_USER /var/www && \
  chown -R $APP_USER $APP_USER_HOME

# Layer 6. Создаем и указываем директорию в которую будет помещено приложение. Так же теперь команды RUN, ENTRYPOINT, CMD будут запускаться с этой директории.
WORKDIR $APP_HOME

# Layer 7. Указываем все команды, которые будут выполняться от имени app пользователя
USER $APP_USER

# Layer 8. Добавляем файлы Gemfile и Gemfile.lock из директории, где лежит Dockerfile (root директория приложения на HostOS) в root директорию WORKDIR
COPY Gemfile Gemfile.lock ./

# Layer 9. Вызываем команду по установке gem-зависимостей. Рекомендуется запускать эту команду от имени пользователя от которого будет запускаться само приложение
RUN bundle check || bundle install

# Layer 10. Копируем все содержимое директории приложения в root-директорию WORKDIR
COPY . .

# Layer 11. Указываем все команды, которые будут выполняться от имени root пользователя
USER root

# Layer 12. Даем root пользователем пользователю app права owner'а на WORKDIR
RUN chown -R $APP_USER:$APP_USER "$APP_HOME/."

# Layer 13. Указываем все команды, которые будут выполняться от имени app пользователя
USER $APP_USER

# Layer 14. Запускаем команду для компиляции статических (JS и CSS) файлов
RUN bin/rails assets:precompile

# Layer 15. Указываем команду по умолчанию для запуска будущего контейнера. По скольку в `Layer 13` мы переопределили пользователя, то puma сервер будет запущен от имени www-data пользователя.
CMD bundle exec puma -C config/puma.rb
