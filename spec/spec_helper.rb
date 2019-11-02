# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

Dir.glob(File.join(File.dirname(__FILE__),
                   '..' + File::SEPARATOR + 'lib', '**',
                   '*.rb'), &method(:require))

require 'factory_bot'
require 'pry'

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
