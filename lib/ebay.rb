require 'json'
require 'ebay_client'
require 'active_support/basic_object'
require './lib/product'

class Ebay
  attr_accessor :config, :payload

  def initialize(payload, config={})
    @payload = payload
    @config = config
    @ebay_client_api = EbayClient::Api.new(EbayClient::Configuration.new({ routing: :default, siteid: 0, preload: false, version: 809, warning_level: :High, error_language: :en_US, api_keys: [{ token: @config[:user_token], devid: @config[:devid], appid: @config[:appid], certid: @config[:certid]}], savon_log_level: :info, url: 'https://api.sandbox.ebay.com/wsapi', wsdl_file: 'http://developer.ebay.com/webservices/809/eBaySvc.wsdl' }))
  end

  def add_product
    product = Product.new(payload, config)
    @ebay_client_api.add_item({:item => { :title => 'second product', :currency => 'USD', :country => 'US', :listing_duration =>'Days_7', :location =>'DElhi', :primary_category => { :category_ID => 377 }, :return_policy => { :returns_accepted_option => 'ReturnsAccepted', :RefundOption => 'MoneyBack', :ReturnsWithinOption => 'Days_30', :Description => '30', :ShippingCostPaidByOption => 'Buyer'}, :StartPrice => 1.00, :PaymentMethods => 'PayPal', :PayPalEmailAddress => 'nishant.tuteja@vinsol.com', :ConditionID => 3000, :ShippingDetails => { :ShippingType => 'Flat', :ShippingServiceOptions => { :ShippingServicePriority => 1, :ShippingService => 'USPSMedia', :ShippingServiceCost => 2.50 } }, :DispatchTimeMax => 3, :Description => 'walla hu' }})
  end
end