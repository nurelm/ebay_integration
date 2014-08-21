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
    ebay = Ebay.new(@payload, @config)
    ebay.add_product
    result 200
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