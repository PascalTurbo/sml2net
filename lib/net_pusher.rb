require 'net/http'
require_relative 'sml/sml_message'

# Net Pusher
class NetPusher
  # Take the readings from reader and push it to a webservice
  def push(readings)
    time = Time.now.to_i
    uri = URI.parse('http://192.168.0.21/reading.json')

    readings.each do |r|
      req = Net::HTTP::Post.new uri.path
      req.body = { 'id' => r.id, 'value' => r.value, 'time' => time }.to_json
      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request req
      end
    end
  end
end
