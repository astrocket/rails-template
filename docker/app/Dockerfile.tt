FROM ruby:<%= RUBY_VERSION %>-alpine

RUN apk add --no-cache --update \
    nano \
    curl-dev \
    ca-certificates \
    linux-headers \
    build-base \
    libxml2-dev \
    libxslt-dev \
    tzdata \
    postgresql-dev \
    nodejs \
    yarn

ARG APP_NAME

ENV RAILS_ROOT $APP_NAME

RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ENV RAILS_ENV='production'
ENV BUNDLE_PATH /bundle

COPY package.json yarn.lock ./
RUN yarn install --production

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.0.1
RUN bundle install --jobs 20 --retry 5 --without development test

COPY . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

RUN ["chmod", "+x", "./docker/app/run.sh"]
