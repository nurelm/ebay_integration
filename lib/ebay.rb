require 'json'
require 'ebay_client'
require 'active_support/basic_object'
require './lib/product'
require './lib/shipment'
require './lib/configuration'

class Ebay
  attr_accessor :config, :payload

  def initialize(payload, config={})
    @payload = payload
    @config = config
    @ebay_client_api = EbayClient::Api.new(Configuration.new(@config).ebay_client_config)
  end

  def add_product
    product = Product.new(payload, config)
    @ebay_client_api.add_fixed_price_item product.ebay_product
  end

  def update_product
    product = Product.new(payload, config)
    @ebay_client_api.revise_fixed_price_item product.ebay_product
  end

  def get_products
    product = Product.new(payload, config)
    p @ebay_client_api.get_seller_list product.search_params
  end

  def add_shipment
    shipment = Shipment.new(payload, config)
    @ebay_client_api.complete_sale shipment.ebay_shipment
  end
end