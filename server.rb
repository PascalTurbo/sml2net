require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

# Receives the requests from the client(s)
# and stores the result in the background storage
post '/reading' do
  puts "These are the params: #{params}"
  reading = JSON.parse(params[:data])
  puts reading
end
