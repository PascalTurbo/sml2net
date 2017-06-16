require 'mqtt'

class MqttClient
  def initialize
    @history = {}
  end

  def push(readings, device_id)
    MQTT::Client.connect('mqtt://openhab:RmAvMpbc6ueDEMyByzGnJarFnMjP3c@homecontrol') do |c|
      readings.each do |r|
        key = "#{device_id}_#{r.id}"
        pub = false
        if @history[key].nil?
          @history[key] = [r.value]
        else
          history = @history[key]
          history.shift if history.length > 5
          # puts "KEY ********** #{key}"
          # only push larger values
          pub = history.min <= r.value
          # puts "min: #{history.min}, current: #{r.value}" unless pub
          # but not to much larger than last value
          pub = pub && (history.max + 50.0) > r.value
          # puts "max + 50.0: #{history.max + 50.0}, current: #{r.value}" unless pub
          # only push if value differnt from last value
          pub = pub && r.value > history.last
	  # puts "last: #{history.last}, current: #{r.value}" unless pub
          # skip if value smaller 0
          pub = pub && r.value > 0          
        end
        if pub
          c.publish("openHAB/slave/#{device_id}_#{r.id}/state", r.value)
          @history[key] << r.value
        end
      end
    end
  end
end
