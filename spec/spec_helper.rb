# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter %r{/spec/}
  enable_coverage :branch
  primary_coverage :branch
end

Dir.glob(File.join(File.dirname(__FILE__),
                   "..#{File::SEPARATOR}lib", '**',
                   '*.rb')).each(&method(:require))

require 'factory_bot'

ENV['CLEAR_TERM'] = '0'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
