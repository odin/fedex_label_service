# frozen_string_literal: true

require 'fedex_label_service/version'
require 'fedex_label_service/configuration'
require 'fedex_label_service/ground_message'
require 'fedex_label_service/smartpost_message'

require 'savon'

module FedexLabelService
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.root
    Pathname.new File.expand_path('..', __dir__)
  end

  def self.message(service, sender_attributes, recipient_attributes)
    if service == 'smartpost'
      message = FedexLabelService::SmartpostMessage.build(sender_attributes, recipient_attributes)
    elsif service == 'ground'
      message = FedexLabelService::GroundMessage.build(sender_attributes, recipient_attributes)
    end

    message
  end

  def self.call(message)
    client = Savon.client(wsdl: FedexLabelService.configuration.wsdl)

    begin
      @response = client.call(:process_shipment, message: message)
    rescue Savon::SOAPFault => error
      puts error.http.inspect
    end

    @response
  end

  def self.parsed_response(response)
    {
      tracking_number: response.body[:process_shipment_reply][:completed_shipment_detail][:completed_package_details][:tracking_ids][:tracking_number],
      label_data:      response.body[:process_shipment_reply][:completed_shipment_detail][:completed_package_details][:label][:parts][:image]
    }
  end
end
