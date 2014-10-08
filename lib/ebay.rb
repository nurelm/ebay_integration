require 'json'
require 'ebay_client'
require 'active_support/basic_object'
require './lib/product'
require './lib/shipment'
require './lib/configuration'
require './lib/order'
require './lib/inventory'

class Ebay
  attr_accessor :config, :payload

  def initialize(payload, config={})
    @payload = payload
    @config = config
    @ebay_client_api = EbayClient::Api.new(Configuration.new(@config).ebay_client_config)
  end

  def get_session_id
    @ebay_client_api.get_session_i_d ru_name: 'VinSol-VinSole1c-e6f9--dftqd' #ru_name
  end

  def fetch_token
    @ebay_client_api.fetch_token session_i_d: payload[:session_id]
  end

  def add_product
    product = Product.new(payload, config)
    @ebay_client_api.add_fixed_price_item product.ebay_product
  end

  def update_product
    product = Product.new(payload, config)
    @ebay_client_api.revise_fixed_price_item product.ebay_product
  end

  def set_inventory
    inventory = Inventory.new(payload, config)
    @ebay_client_api.revise_inventory_status inventory.ebay_inventory
  end

  def get_products
    product = Product.new(payload, config)
    @ebay_client_api.get_seller_list product.search_params
  end

  def get_orders
    order = Order.new(config)
    @ebay_client_api.get_orders order.search_params
  end

  def add_shipment
    shipment = Shipment.new(payload, config)
    @ebay_client_api.complete_sale shipment.ebay_shipment
  end

  private
    def ru_name
      sandbox? ? ENV['SANDBOX_RU_NAME'] : ENV['PRODUCTION_RU_NAME']
    end

    def sandbox?
      payload[:sandbox] != '0'
    end
end