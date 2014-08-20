require 'sinatra'
require 'json'

class EbayIntegration < Sinatra::Base
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
    [@payload.inspect, @config.inspect]
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