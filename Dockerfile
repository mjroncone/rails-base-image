# This image should be rebuilt infrequently. It serves at the base image for a rails app.
# When building, tag with the name rails-base and then either latest or test tag
FROM ubuntu:20.04

# Prevent tzdata asking for geographic area
ARG DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update \
  && apt-get install -y autoconf build-essential curl gpg lsb-release make \
    python3 python3-distutils wget zlib1g-dev libssl-dev libpq-dev \
    ca-certificates

# Set apt up for nginx
RUN echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
  | tee /etc/apt/sources.list.d/nginx.list \
  && echo "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx \
  && curl -o /etc/apt/trusted.gpg.d/nginx_signing.asc https://nginx.org/keys/nginx_signing.key

# Set apt up for PostgreSQL
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
  > /etc/apt/sources.list.d/pgdg.list \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get install -y nginx postgresql-13

# Install Ruby and Bundler
WORKDIR /usr/tmp/ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.2.tar.gz -O ruby.tar.gz \
  && tar --strip-components=1 -xzf ruby.tar.gz \
  && autoconf \
  && ./configure \
  && make \
  && make install \
  && rm -rf ./*
RUN gem install bundler:2.2.11

# Install Node and Yarn
WORKDIR /usr/tmp/node
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs
RUN npm install -g yarn

WORKDIR /
