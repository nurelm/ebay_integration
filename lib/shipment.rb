require 'json'

class Shipment
  def initialize(wombat_shipment, config={})
    @wombat_shipment = wombat_shipment["shipment"]
    @config = config
    @ebay_shipment = Hash.new
  end

  def ebay_shipment
    @ebay_shipment[:OrderID] = @wombat_shipment['ebay_order_id']
    @ebay_shipment[:shipped] = true unless @wombat_shipment['shipped_at'].strip.empty?

    @ebay_shipment[:Shipment] = {}
    @ebay_shipment[:Shipment][:ShipmentTrackingDetails] = {}
    @ebay_shipment[:Shipment][:ShippedTime] = @wombat_shipment["shipped_at"]

    @ebay_shipment[:Shipment][:ShipmentTrackingDetails][:ShipmentTrackingNumber] = @wombat_shipment["tracking"]
    @ebay_shipment[:Shipment][:ShipmentTrackingDetails][:ShippingCarrierUsed] = @wombat_shipment["shipping_method"].gsub(/[^A-z0-9\ ]/, '')
    @ebay_shipment
  end

  def self.wombat_shipment_hash(ebay_order)
    wombat_shipment = {}

    { "id" => :order_id, "ebay_order_id" => :order_id }.each do |wombat_key, ebay_value|
      wombat_shipment[wombat_key] = ebay_shipment[ebay_value]
    end

    wombat_shipment["tracking"] = ebay_order[:shipping_details][:shipment_tracking_details][:shipment_tracking_number]
    wombat_shipment["shipping_method"] = ebay_order[:shipping_details][:shipment_tracking_details][:shipping_carrier_used]

    wombat_shipment["shipped_at"] = ebay_order[:shipped_time]

    wombat_shipment["shipping_address"] = {}

    { "first_name" => :name, "address1" => :street1, "address2" => :street2, "city" => :city, "state" => :state, "zipcode" => :postal_code, "country" => :country, "phone" => :phone }.each do |wombat_key, ebay_value|
      wombat_shipment["shipping_address"][wombat_key] = ebay_order[:shipping_address][ebay_value]
    end

    wombat_shipment
  end
end