require 'sinatra'
require 'json'
require_relative 'server/reading.rb'

set :bind, '0.0.0.0'

# Receives the requests from the client(s)
# and stores the result in the background storage
post '/reading.?.:format?' do
  reading = JSON.parse(request.body.read, symbolize_names: true)

  r = Reading.new
  r.meter_id = reading[:id]
  r.value = reading[:value]
  r.time = reading[:time]

  r.save

  puts reading

#  puts Reading.methods
  puts "Current Count: #{Reading.find_all_by_attribute(:meter_id, '181').count}"
end
