require 'sinatra' 
require 'json' 

class EbayIntegration < Sinatra::Base 
  get '/' do 
    "Hello World" 
  end 
end