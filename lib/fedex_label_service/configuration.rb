# frozen_string_literal: true

module FedexLabelService
  class Configuration
    attr_accessor :wsdl
    attr_accessor :key
    attr_accessor :password
    attr_accessor :account_number
    attr_accessor :meter_number
    attr_accessor :hub_id

    def initialize
      @wsdl           = nil
      @key            = nil
      @password       = nil
      @account_number = nil
      @meter_number   = nil
      @hub_id         = nil
    end
  end
end
