FROM ruby:2.6.6-alpine as builder

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

# Allows for better caching
ADD Gemfile Gemfile.lock /app/

WORKDIR /app
RUN bundle install && \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems -name "*.[co]" -delete

ADD . /app

RUN bundle exec rake assets:precompile

#
# The final image: start clean
#
FROM ruby:2.6.6-alpine

# Get the box updated and install any necessary runtime packages
RUN apk --no-cache update && apk --no-cache upgrade && \
    apk --no-cache add \
      mariadb-dev \
      nodejs-current \
      sqlite-dev \
      tzdata && \
    # update bundler so we can run rails
    gem update --system

# Set timezone
ENV TZ=America/Denver
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo "$TZ" > /etc/timezone

RUN mkdir /app
WORKDIR /app

COPY --from=builder /app/ /app/
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
