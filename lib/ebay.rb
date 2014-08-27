require 'json'
require 'ebay_client'
require 'active_support/basic_object'
require './lib/product'
require './lib/configuration'

class Ebay
  attr_accessor :config, :payload

  def initialize(payload, config={})
    @payload = payload
    @config = config
    @ebay_client_api = EbayClient::Api.new(Configuration.new(@config))
  end

  def add_product
    product = Product.new(payload, config)
    @ebay_client_api.add_fixed_price_item product.ebay_product
  end

  def get_products
    product = Product.new(payload, config)
    @ebay_client_api.get_seller_list
  end
end