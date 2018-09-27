# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'dotenv/load'
require 'fedex_label_service'
require 'vcr'

Dir[FedexLabelService.root.join('spec/support/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each, smartpost: true) do
    FedexLabelService.configure do |c|
      c.wsdl           = ENV['WSDL']
      c.key            = ENV['KEY']
      c.password       = ENV['PASSWORD']
      c.account_number = ENV['ACCOUNT_NUMBER']
      c.meter_number   = ENV['METER_NUMBER']
      c.hub_id         = ENV['HUB_ID']
    end
  end

  config.before(:each, ground: true) do
    FedexLabelService.configure do |c|
      c.wsdl           = ENV['WSDL']
      c.key            = ENV['KEY']
      c.password       = ENV['PASSWORD']
      c.account_number = ENV['ACCOUNT_NUMBER']
      c.meter_number   = ENV['METER_NUMBER']
    end
  end

  config.after(:each) do
    FedexLabelService.reset
  end
end
