require 'sinatra'
require 'json'
require 'endpoint_base'
require './lib/ebay'

class EbayIntegration < EndpointBase::Sinatra::Base
  enable :logging

  get '/get_products' do
    "Coming Soon..."
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
    logger.info @payload.inspect
    response = Ebay.new(@payload, @config).add_product
    if response.ack.eq('Success')
      result 200
    else
      result 500, response.errors.first.long_message
    end
  end

  post '/update_product' do
    "Coming Soon..."
  end

  post '/add_shipment' do
    "Coming Soon..."
  end

  post '/update_shipment' do
    "Coming Soon..."
  end
end