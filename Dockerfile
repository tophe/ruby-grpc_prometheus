FROM ruby:2.6.2

ENV BUNDLE_PATH /vendor/bundle
WORKDIR /app
ADD . /app
