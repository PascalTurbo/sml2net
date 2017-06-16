require 'mqtt'

class MqttClient
  def push(readings, device_id)
    MQTT::Client.connect('mqtt://openhab:RmAvMpbc6ueDEMyByzGnJarFnMjP3c@homecontrol') do |c|
      readings.each do |r|
        c.publish("openHAB/slave/#{device_id}_#{r.id}/state", r.value)
      end
    end
  end
end
