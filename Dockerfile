FROM ruby:2.5.1-alpine

RUN apk add --update \
  build-base \
  nodejs \
  postgresql-dev \
  tzdata \
  yarn \
  && rm -rf /var/cache/apk/*

RUN mkdir /web_analytics
WORKDIR /web_analytics

COPY Gemfile* /web_analytics/
RUN bundle install --jobs 4

COPY . /web_analytics
