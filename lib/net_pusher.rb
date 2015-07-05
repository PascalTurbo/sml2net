require 'net/http'
require 'json'
require_relative 'sml/sml_message'

# Net Pusher
class NetPusher
  # Take the readings from reader and push it to a webservice
  def push(readings)
    uri = URI.parse('http://192.168.0.21:4567/reading')
#    begin
      readings.each do |r|
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = { 'data' => { id: r.id, value: r.value, time: r.time } }.to_json
        
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request req
        end
      end
#    rescue StandardError
#      return
#    end
  end
end
