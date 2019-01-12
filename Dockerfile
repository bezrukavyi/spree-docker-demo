FROM ruby:2.5-slim

# Все следующие команды будут выполнятся от имени root пользователя
USER root

# Устанавливаем ПО, необходимое для корректной работы приложения:
ENV BUILD_PACKAGES build-essential libpq-dev libxml2-dev libxslt1-dev nodejs imagemagick apt-transport-https curl nano
RUN apt-get update -qq && apt-get install -y $BUILD_PACKAGES

# Устанавливаем пакетный менеджер Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install --no-install-recommends yarn

# В environment переменную `APP_HOME` запишем путь, по которому будет находиться наше приложение внутри Docker образа:
ENV APP_HOME /home/www/spreedemo
WORKDIR $APP_HOME

# Добавляем в текущий WORKDIR Gemfile и Gemfile.lock и вызываем команду по установке gem зависимостей. При отсутствии изменений в Gemfile и Gemfile.lock при следующем выполнении команды будет использоваться кэш:
COPY Gemfile Gemfile.lock ./
RUN bundle check || bundle install

# В текущий wordkir добавляем все содержание приложения
COPY . .

# Даем www-data пользователю права owner'а на необходимые директории:
RUN mkdir /var/www && \
  chown -R www-data:www-data /var/www && \
  chown -R www-data:www-data "$APP_HOME/."

# Все последующие команды будут выполняться от имени www-data пользователя:
USER www-data

# Поместим в образ скомпилированные assets:
RUN bundle exec rake assets:precompile

# Команды которые, будут выполнены только перед запуском контейнера:
COPY docker-entrypoint.sh ./
ENTRYPOINT [ "./docker-entrypoint.sh" ]

# Команда по умолчанию для запуска образа:
CMD bundle exec puma -C config/puma.rb
