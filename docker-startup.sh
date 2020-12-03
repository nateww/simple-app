#!/bin/sh -e
exec bundle exec puma -C config/puma.rb
