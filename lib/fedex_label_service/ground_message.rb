# frozen_string_literal: true

module FedexLabelService
  class GroundMessage
    def self.build(sender_attributes, recipient_attributes)
      recipient_street = "#{recipient_attributes[:address_one]} #{recipient_attributes[:address_two]}"
      sender_street    = "#{sender_attributes[:address_one]} #{sender_attributes[:address_two]}"
      sender_name      = "#{sender_attributes[:first_name]} #{sender_attributes[:last_name]}"

      {
        'WebAuthenticationDetail' => [
          'ParentCredential' => [
            'Key'      => FedexLabelService.configuration.key,
            'Password' => FedexLabelService.configuration.password
          ],
          'UserCredential' => [
            'Key'      => FedexLabelService.configuration.key,
            'Password' => FedexLabelService.configuration.password
          ]
        ],
        'ClientDetail' => [
          'AccountNumber' => FedexLabelService.configuration.account_number,
          'MeterNumber'   => FedexLabelService.configuration.meter_number
        ],
        'TransactionDetail' => [
          'CustomerTransactionId' => 'label_service gem Ground Request'
        ],
        'Version' => [
          'ServiceId'    => 'ship',
          'Major'        => '21',
          'Intermediate' => '0',
          'Minor'        => '0'
        ],
        'RequestedShipment' => [
          'ShipTimestamp' => Time.now.iso8601,
          'DropoffType'   => 'BUSINESS_SERVICE_CENTER',
          'ServiceType'   => 'FEDEX_GROUND',
          'PackagingType' => 'YOUR_PACKAGING',
          'Shipper' => [
            'Contact' => [
              'PersonName'  => sender_name,
              'CompanyName' => sender_name,
              'PhoneNumber' => sender_attributes[:phone]
            ],
            'Address' => [
              'StreetLines' => [
                sender_street
              ],
              'City'                => sender_attributes[:city],
              'StateOrProvinceCode' => sender_attributes[:state],
              'PostalCode'          => sender_attributes[:postal_code],
              'CountryCode'         => 'US'
            ]
          ],
          'Recipient' => [
            'Contact' => [
              'PersonName'  => recipient_attributes[:name],
              'CompanyName' => recipient_attributes[:company],
              'PhoneNumber' => recipient_attributes[:phone]
            ],
            'Address' => [
              'StreetLines' => [
                recipient_street
              ],
              'City'                => recipient_attributes[:city],
              'StateOrProvinceCode' => recipient_attributes[:state],
              'PostalCode'          => recipient_attributes[:postal_code],
              'CountryCode'         => 'US'
            ]
          ],
          'ShippingChargesPayment' => [
            'PaymentType' => 'SENDER',
            'Payor'       => [
              'ResponsibleParty' => [
                'AccountNumber' => FedexLabelService.configuration.account_number,
                'Contact' => [],
                'Address' => [
                  'CountryCode' => 'US'
                ]
              ]
            ]
          ],
          'SpecialServicesRequested' => [
            'SpecialServiceTypes' => 'RETURN_SHIPMENT',
            'ReturnShipmentDetail' => [
              'ReturnType' => 'PRINT_RETURN_LABEL'
            ]
          ],
          'LabelSpecification' => [
            'LabelFormatType' => 'COMMON2D',
            'ImageType'       => 'PNG',
            'LabelStockType'  => 'PAPER_4X6'
          ],
          'PackageCount' => 1,
          'RequestedPackageLineItems' => [
            'SequenceNumber' => 1,
            'Weight' => [
              'Units' => 'LB',
              'Value' => 2.0
            ],
            'CustomerReferences' => [
              'CustomerReferenceType' => 'CUSTOMER_REFERENCE',
              'Value'                 => sender_attributes[:customer_reference]
            ]
          ]
        ]
      }
    end
  end
end
