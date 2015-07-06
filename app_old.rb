require 'json'
require 'net/http'
require 'rubyserial'
require_relativ 'lib/sml/sml_message'

serialport = Serial.new '/dev/lesekopf0', 9600
test = true

# Send the readings to emon cms
class UpdatePusher
  def initialize
    @last_values = {}
    @last_pushes = {}
    @median_values = {}
  end

  def push(reading)
    last_value = @last_values[reading.id.to_s] ||= 0
    #return if  last_value > reading.value
    #return if reading.value == 1.0

    # Nur jede Minute pushen
    current_time = Time.now.to_i
    if @last_pushes[reading.id.to_s].nil?
      @last_pushes[reading.id.to_s] = current_time
    end
    if @last_pushes[reading.id.to_s] < (current_time - 5)
      @last_pushes[reading.id.to_s] = current_time
    else
      return
    end
#    url = URI.parse('http://79.143.178.150:10580/emoncms/input/post.json')
#    form = { 'json' => "#{reading.id}:#{reading.value}",
#             'apikey' => '86952235904a17c8de6b2e56315ce79d',
#             'time' => reading.time.to_i,
#             'node' => 1 }
#    url.query = URI.encode_www_form(form)
    item_name = nil

    if reading.id == '281' 
  item_name = 'PowerProduction_Meter_PV'
    else 
      return
    end

    # Simple Window Function 
    # Don't report the value if it differs more than factor 1.2
    min_value = last_value * 0.8
    max_value = last_value * 1.2
    
    if reading.value > max_value || reading.value < min_value
      # HACK
      item_name = nil
      puts "Skip mecause of window function"
    end

    # Noch mehr hack. Korrekt: Prüfe wie das mit der Checksum funktioniert
    
    if @median_values[reading.id.to_s].nil?
        @median_values[reading.id.to_s] = []
    end

    if @median_values[reading.id.to_s].length > 100
        @median_values[reading.id.to_s].shift
    end

    if @median_values[reading.id.to_s].length < 10
        item_name = nil
        puts "Not enough values (#{@median_values[reading.id.to_s].length}) for average calculation. Skip posting"
    end


    median = @median_values[reading.id.to_s].inject(0.0) { |sum, el| sum + el } / @median_values[reading.id.to_s].size
    
    # Soll starke Abweichungen vom Mittel der letzten Werte verhindern
    if reading.value > (median * 1.5) || reading.value < (median * 0.5)
        item_name = nil
        puts "Skip value (#{reading.value}) because of average #{median}"
    end

    

    begin
      #Net::HTTP.get(url)
      unless item_name.nil?
  # puts "Reading id: #{reading.id}, Item Name: #{item_name}"
        port = 8080
        host = '192.168.0.25'
        path = "/rest/items/#{item_name}/state"

        req = Net::HTTP::Put.new(path, initheader = { 'Content-Type' => 'text/plain'})
        req.body = reading.value.to_s
        res = Net::HTTP.new(host, port).start { |http| http.request(req) }
        #puts res.code
      end
      puts "ID: #{reading.id}, Value: #{reading.value}}}"
    rescue StandardError => e
      puts "Couldn't push value to server #{e.message}"
    end

    @last_values[reading.id.to_s] = reading.value
    @median_values[reading.id.to_s] << reading.value
  end
end

sml = SmlMessage.new
pusher = UpdatePusher.new

while test
  byte = serialport.getbyte

  if sml.finished?
    sml.readings.each do | r |
      pusher.push(r)
    end

    #puts sml.to_s
    sml = SmlMessage.new
  else
    sml << byte unless byte.nil?
  end
end
