require 'json'
require 'ebay_client'
require 'active_support/basic_object'
require './lib/product'

class Ebay
  attr_accessor :config, :payload

  def initialize(payload, config={})
    @payload = payload
    @config = config
    @ebay_client_api = EbayClient::Api.new(EbayClient::Configuration.new({ routing: :default, siteid: 0, preload: false, warning_level: :High, error_language: :en_US, api_keys: [{ token: @config[:user_token], devid: @config[:devid], appid: @config[:appid], certid: @config[:certid]}], savon_log_level: :info, url: 'https://api.sandbox.ebay.com/wsapi', wsdl_file: 'http://developer.ebay.com/webservices/809/eBaySvc.wsdl' }))
  end

  def add_product
    product = Product.new(payload, config)
    @ebay_client_api.add_item product.ebay_product
  end
end