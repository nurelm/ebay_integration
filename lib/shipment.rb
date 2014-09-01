require 'json'

class Shipment
  def initialize(wombat_shipment, config={})
    @wombat_shipment = wombat_shipment["shipment"]
    @config = config
    @ebay_shipment = Hash.new
  end

  def ebay_shipment
    @ebay_shipment[:OrderID] = @wombat_shipment["order_id"].gsub(/\A(R)/, '')
    @ebay_shipment[:Shipment] = {}
    @ebay_shipment[:Shipment][:ShipmentTrackingDetails] = {}
    @ebay_shipment[:Shipment][:ShippedTime] = @wombat_shipment["shipped_at"]

    @ebay_shipment[:Shipment][:ShipmentTrackingDetails][:ShipmentTrackingNumber] = @wombat_shipment["tracking"]
    @ebay_shipment[:Shipment][:ShipmentTrackingDetails][:ShippingCarrierUsed] = @wombat_shipment["shipping_method"].gsub(/[^A-z0-9\ ]/, '')
    @ebay_shipment
  end
end