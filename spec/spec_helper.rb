require 'bundler'
require 'rubygems'

Bundler.require(:default, :test)

Dir['./lib/**/*.rb'].each(&method(:load))
Dir['./spec/support/*.rb'].each(&method(:load))

Sinatra::Base.environment = 'test'
