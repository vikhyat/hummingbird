source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'pg'
gem 'mongoid', '~> 3.0.0'

gem 'redis'
gem 'redis-rails'

gem 'forem', :path => 'vendor/forem'
gem 'forem-html_formatter', :path => 'vendor/forem-html_formatter'
gem 'rinku'

gem 'sanitize'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'zurb-foundation', '~> 4.0.0'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

# Gems to help with development.
group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :production do
  gem 'newrelic_rpm'
end

# Testing
group :test do
  gem 'shoulda'
  gem "tarantula", :require => "tarantula-rails3"
  gem 'factory_girl_rails'
  gem 'simplecov'
end

gem 'jquery-rails'
gem 'haml', '~> 4.0'
gem 'haml-rails'
gem 'simple_form'
gem 'rdiscount'

# Attachments
gem "paperclip", "~> 3.0"

# Better URLs.
gem 'friendly_id', '~> 4.0.9'

# Authentication.
gem 'devise'
gem 'devise-async' # Async email for Devise
gem 'omniauth'
gem 'omniauth-facebook', '= 1.4.0'  # Using version 1.4.0 instead of the latest
                                    # because of an issue where the first time
                                    # (when the user authorizes the application),
                                    # the user is not logged in for some reason.
# Authorization.
gem 'cancan'

# For pagination.
gem 'kaminari'

# Background jobs
gem 'sidekiq'
gem 'slim'
gem 'sinatra', :require => nil

# Fuzzy Search with Postgres.
gem 'pg_search', git: "git@github.com:Casecommons/pg_search.git"

# Admin panel
gem "rails_admin"

# For voting on stuff.
gem "activerecord-reputation-system", require: 'reputation_system'

# Use Unicorn as the app server
gem 'unicorn'

# Needed for MAL import.
gem 'nokogiri', require: false

# Deploy with Capistrano
gem 'capistrano'
gem 'rvm-capistrano'

# Image optimization
gem 'image_optim', require: false

# Metrics
gem 'mixpanel'

# A/B Testing
gem 'split'

# SEO
gem 'sitemap_generator'
