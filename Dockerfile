FROM ruby:2.6.6-alpine

# System prerequisites
RUN apk --no-cache update && apk --no-cache upgrade && \
    apk --no-cache add \
      build-base \
      curl && \
    gem update --system


ADD Gemfile Gemfile.lock /app/

WORKDIR /app
RUN bundle install

ADD . /app

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review http://go.aptible.com/assets for production-ready advice.
RUN set -a && \
    . ./.aptible.env && \
    bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
