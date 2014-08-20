require 'sinatra'
require 'json'
require 'endpoint_base'

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
    logger.info request
    logger.info @payload
    result 200, [@payload.inspect, @config.inspect]
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