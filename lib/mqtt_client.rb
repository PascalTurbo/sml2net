require 'mqtt'

class MqttClient
  def push(readings, device_id)
    MQTT::Client.connect('homecontrol') do |c|
      readings.each do |r|
        c.publish("openHAB/energy/#{device_id}/state", r.value)
      end
    end
  end
end
