#!/bin/sh -e
bundle exec rake db:migrate
exec bundle exec puma -C config/puma.rb
