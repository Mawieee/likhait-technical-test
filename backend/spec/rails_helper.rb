# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'database_cleaner/active_record'

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # Disable Rails' built-in transactional fixtures.
  # We handle cleanup explicitly via DatabaseCleaner below so that we have
  # full control over when and how data is cleared between tests.
  config.use_transactional_fixtures = false

  # DatabaseCleaner setup for request specs:
  #
  # We use the :truncation strategy (rather than :transaction) for ALL specs
  # because request specs go through the full Rack stack. In that path, Rails
  # opens its own separate DB connection for each request, which cannot see
  # data that is locked inside a test-level transaction. Using :truncation
  # avoids that isolation problem entirely.
  #
  # - before(:suite)  -> do a full truncation once before any example runs.
  #   This wipes rows inserted by Docker's init.sql or any previous run.
  # - before(:each)   -> start a DatabaseCleaner session.
  # - after(:each)    -> truncate all tables so the next test starts clean.
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
