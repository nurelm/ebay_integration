require 'sinatra' 
require 'json' 

class EbayIntegration < Sinatra::Base 
  get '/' do 
    return 200, "Coming Soon..." 
  end

  get '/get_products' do 
    return 200, "Coming Soon..." 
  end

  post '/get_orders' do 
    return 200, "Coming Soon..." 
  end

  post '/get_products' do 
    return 200, "Coming Soon..." 
  end

  post '/set_inventory' do 
    return 200, "Coming Soon..." 
  end

  post '/add_product' do 
    return 200, "Coming Soon..." 
  end

  post '/update_product' do 
    return 200, "Coming Soon..." 
  end

  post '/add_shipment' do 
    return 200, "Coming Soon..." 
  end

  post '/update_shipment' do 
    return 200, "Coming Soon..." 
  end
end