require 'sinatra'
require 'json'
require 'endpoint_base'
require './lib/ebay'

class EbayIntegration < EndpointBase::Sinatra::Base
  enable :logging

  post '/get_products' do
    response = Ebay.new(@payload, @config).get_products
    if response.success?
      add_parameter 'ebay_start_time_from', Time.now - 30*24*60*60
      add_parameter 'ebay_start_time_to', Time.now - 30*24*60*60
      add_parameter 'ebay_page_number', @config[:ebay_page_number].to_i + 1 if response.payload[:has_more_items]

      response.payload[:item_array][:item].each do |item|
        add_object 'product', Product.wombat_product_hash(item)
      end

      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/get_orders' do
    "Coming Soon..."
  end

  post '/set_inventory' do
    "Coming Soon..."
  end

  post '/add_product' do
    response = Ebay.new(@payload, @config).add_product
    if response.success?
      add_object 'product', @payload[:product].merge({ ebay_item_id: response.payload[:item_id] })
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