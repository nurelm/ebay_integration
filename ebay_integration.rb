require 'sinatra' 
require 'json' 

class EbayIntegration < Sinatra::Base 
  get '/' do 
    "Hello World" 
  end

  get '/get_products' do 
    "Hello World" 
  end

  post '/get_products' do 
    "Hello World" 
  end
end