FROM ruby:2.6.6-alpine

# System prerequisites
RUN apk --no-cache update && apk --no-cache upgrade && \
    apk --no-cache add \
      build-base \
      curl \
      mariadb-dev \
      nodejs-current \
      sqlite-dev \
      tzdata && \
    gem update --system

# Set the timezone
ENV TZ=America/Denver
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "$TZ" > /etc/timezone

# Allows for better caching
ADD Gemfile Gemfile.lock /app/

WORKDIR /app
RUN bundle install

ADD . /app

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
