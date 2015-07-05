require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

# Receives the requests from the client(s)
# and stores the result in the background storage
post '/reading.?.:format?' do
  reading = JSON.parse request.body.read
  puts reading
end
