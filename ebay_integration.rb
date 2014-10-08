require 'sinatra'
require 'json'
require 'endpoint_base'
require './lib/ebay'

class EbayIntegration < EndpointBase::Sinatra::Base
  enable :logging

  post '/get_session_id' do
    response = Ebay.new(@payload, @config).get_session_id

    if response.success?
      result 200, response.payload[:session_id]
    else
      result 500, 'Something Went Wrong. Please try again.'
    end
  end

  post '/fetch_token' do
    response = Ebay.new(@payload, @config).fetch_token

    if response.success?
      result 200, response.payload[:e_bay_auth_token]
    else
      result 500, 'Something Went Wrong. Please try again.'
    end
  end

  post '/get_products' do
    response = Ebay.new(@payload, @config).get_products
    if response.success?
      add_parameter 'ebay_start_time_from', Time.now - 30*24*60*60
      add_parameter 'ebay_start_time_to', Time.now - 30*24*60*60
      add_parameter 'ebay_page_number', (response.payload[:has_more_items] ? @config[:ebay_page_number].to_i + 1 : 1)

      [response.payload[:item_array][:item]].flatten.each do |item|
        add_object 'product', Product.wombat_product_hash(item)
        Inventory.wombat_inventories_hash(item).each { |inventory_hash| add_object 'inventory', inventory_hash  }
      end if response.payload[:item_array]

      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/get_orders' do
    response = Ebay.new(@payload, @config).get_orders

    if response.success?
      add_parameter 'ebay_mod_time_from', Time.now - 25*24*60*60
      add_parameter 'ebay_page_number', (response.payload[:has_more_orders] ? @config[:ebay_page_number].to_i + 1 : 1)

      [response.payload[:order_array][:order]].flatten.each do |item|
        add_object 'order', Order.wombat_order_hash(item)
        add_object 'shipment', Shipment.wombat_shipment_hash(item)
      end if response.payload[:order_array]

      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/set_inventory' do
    response = Ebay.new(@payload, @config).set_inventory
    if response.success?
      result 200
    else
      result 500, response.errors.first.long_message
    end
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