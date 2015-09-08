require 'json'

class Shipment
  WOMBAT_SHIPMENT_INITIAL_VALUES_MAPPING ||= { 'id' => :order_id,
                                             'ebay_order_id' => :order_id }
  WOMBAT_SHIPMENT_SHIPPING_VALUES_MAPPING ||= { 'first_name' => :name,
                                              'address1' => :street1,
                                              'address2' => :street2,
                                              'city' => :city,
                                              'state' => :state,
                                              'zipcode' => :postal_code,
                                              'country' => :country,
                                              'phone' => :phone }

  def initialize(wombat_shipment, config={})
    @wombat_shipment = wombat_shipment['shipment']
    @config = config
    @ebay_shipment = Hash.new
  end

  def ebay_shipment
    @ebay_shipment[:OrderID] = @wombat_shipment['ebay_order_id']
    @ebay_shipment[:shipped] = true if shipped_at_present?(@wombat_shipment)
    @ebay_shipment[:Shipment] = ebay_shipment_details(@wombat_shipment)
    @ebay_shipment
  end

  def self.wombat_shipment_hash(ebay_order)
    wombat_shipment = wombat_shipment_initial_values(ebay_order)

    if ebay_order[:shipping_details][:shipment_tracking_details]
      wombat_shipment['tracking'] = ebay_order[:shipping_details][:shipment_tracking_details][:shipment_tracking_number]
      wombat_shipment['shipping_method'] = ebay_order[:shipping_details][:shipment_tracking_details][:shipping_carrier_used]
    end

    wombat_shipment['shipped_at'] = ebay_order[:shipped_time]
    wombat_shipment['shipping_address'] = wombat_shipment_shipping_address(ebay_order)

    wombat_shipment
  end

  private
    def shipped_at_present?(wombat_shipment)
      !wombat_shipment['shipped_at'].strip.empty?
    end

    def ebay_shipment_details(wombat_shipment)
      { :ShippedTime => @wombat_shipment['shipped_at'],
        :ShipmentTrackingDetails => ebay_shipment_tracking_details(@wombat_shipment) }
    end

    def ebay_shipment_tracking_details(wombat_shipment)
      { :ShipmentTrackingDetails => @wombat_shipment['tracking'],
        :ShippingCarrierUsed => @wombat_shipment['shipping_method'].gsub(/[^A-z0-9\ ]/, '') }
    end

    def self.wombat_shipment_initial_values(ebay_order)
      wombat_shipment = {}

      WOMBAT_SHIPMENT_INITIAL_VALUES_MAPPING.each do |wombat_key, ebay_value|
        wombat_shipment[wombat_key] = ebay_order[ebay_value]
      end

      wombat_shipment
    end

    def self.wombat_shipment_shipping_address(ebay_order)
      shipping_address = {}

      WOMBAT_SHIPMENT_SHIPPING_VALUES_MAPPING.each do |wombat_key, ebay_value|
        shipping_address[wombat_key] = ebay_order[:shipping_address][ebay_value]
      end

      shipping_address
    end
end
