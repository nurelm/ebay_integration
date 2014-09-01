require 'sinatra'
require 'json'
require 'endpoint_base'
require './lib/ebay'

class EbayIntegration < EndpointBase::Sinatra::Base
  enable :logging

  post '/get_products' do
    response = Ebay.new(@payload, @config).get_products
    if response.success?
      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/get_orders' do
    "Coming Soon..."
  end

  post '/get_products' do
    "Coming Soon..."
  end

  post '/set_inventory' do
    "Coming Soon..."
  end

  post '/add_product' do
    response = Ebay.new(@payload, @config).add_product
    if response.success?
      add_value 'ebay_item_id', response.payload[:item_id]
      result 200, "Product with #{ response.payload[:item_id] } is added to eBay."
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/update_product' do
    response = Ebay.new(@payload, @config).update_product
    if response.success?
      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/add_shipment' do
    response = Ebay.new(@payload, @config).add_shipment
    if response.success?
      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/update_shipment' do
    response = Ebay.new(@payload, @config).add_shipment
    if response.success?
      result 200
    else
      result 500, response.errors.first.long_message
    end
  end
end