# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FedexLabelService do
  it 'has a version number' do
    expect(FedexLabelService::VERSION).not_to be nil
  end

  before do
    @sender_attributes = {
      first_name:         'The',
      last_name:          'Answer',
      phone:              '1-804-282-1248',
      address_one:        '6008 W Broad St.',
      address_two:        nil,
      city:               'Richmond',
      state:              'VA',
      postal_code:        '23230',
      customer_reference: 'test1234'
    }

    @recipient_attributes = {
      name:        'Receiveing Department',
      company:     'Fundello',
      phone:       '1-804-918-2352',
      address_one: '1400 Commerce Rd.',
      address_two: nil,
      city:        'Richmond',
      state:       'VA',
      postal_code: '23224'
    }
  end

  describe '#configure' do
    before do
      FedexLabelService.configure do |config|
        config.wsdl           = 'http://10.0.20.106'
        config.key            = 'products-api@fundello.com'
        config.password       = 'zer0l0ve'
        config.account_number = 'zer0l0ve'
        config.meter_number   = 'zer0l0ve'
        config.hub_id         = 'hub_id'
      end
    end

    it 'returns the configured options' do
      expect(FedexLabelService.configuration.wsdl).to eq('http://10.0.20.106')
      expect(FedexLabelService.configuration.key).to eq('products-api@fundello.com')
      expect(FedexLabelService.configuration.password).to eq('zer0l0ve')
      expect(FedexLabelService.configuration.account_number).to eq('zer0l0ve')
      expect(FedexLabelService.configuration.meter_number).to eq('zer0l0ve')
      expect(FedexLabelService.configuration.hub_id).to eq('hub_id')
    end
  end

  describe '#message(service, attributes)' do
    context 'when the service is "smartpost"' do
      it 'returns the smartpost message', smartpost: true do
        message = FedexLabelService.message('smartpost', @sender_attributes, @recipient_attributes)

        expect(message['RequestedShipment'][0]['Shipper'][0]['Contact'][0]['PersonName']).to eq('The Answer')
      end
    end

    context 'when the service is "ground"' do
      it 'returns the ground message', ground: true do
        message = FedexLabelService.message('ground', @sender_attributes, @recipient_attributes)

        expect(message['RequestedShipment'][0]['Shipper'][0]['Contact'][0]['PersonName']).to eq('The Answer')
      end
    end
  end

  describe '#call(message)' do
    context 'when the service is "smartpost"' do
      vcr_options = { cassette_name: 'smartpost_label' }

      it 'returns the smartpost shipment with label and tracking number', smartpost: true, vcr: vcr_options do
        label = FedexLabelService.call(FedexLabelService.message('smartpost', @sender_attributes, @recipient_attributes))

        expect(label.body[:process_shipment_reply][:completed_shipment_detail][:completed_package_details][:tracking_ids][:tracking_number]).to eq('02393000043422250204')
      end
    end

    context 'when the service is "ground"' do
      vcr_options = { cassette_name: 'ground_label' }

      it 'returns the ground shipment with label and tracking number', ground: true, vcr: vcr_options do
        label = FedexLabelService.call(FedexLabelService.message('ground', @sender_attributes, @recipient_attributes))

        expect(label.body[:process_shipment_reply][:completed_shipment_detail][:completed_package_details][:tracking_ids][:tracking_number]).to eq('795491814390')
      end
    end
  end

  describe '#parsed_response(response)' do
    vcr_options = { cassette_name: 'smartpost_label' }

    it 'returns a hash with the tracking_number and label data', smartpost: true, vcr: vcr_options do
      response = FedexLabelService.call(FedexLabelService.message('smartpost', @sender_attributes, @recipient_attributes))

      expect(FedexLabelService.parsed_response(response)[:tracking_number]).to eq('02393000043422250204')
      expect(FedexLabelService.parsed_response(response)[:label_data]).to include('iVBORw0KGgoAAAANSUhEUgAAAyAAAASwAQAAAAA')
    end
  end
end
