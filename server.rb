require 'sinatra'

post '/reading/?' do
  jdata = params[:data]
  for_json = JSON.parse(jdata)
  puts for_json
end
