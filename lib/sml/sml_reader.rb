require 'logger'
require 'rubyserial'
require_relative 'sml_message'
require_relative '../mqtt_client'

# SML Reader
class SmlReader
  def initialize(params)
    @device = params[:device]
    @device_id = params[:device_id]
    @serialport = Serial.new @device, 9600
    @running = false
    @logger = Logger.new('sml_reader.log')
    @logger.level = Logger::WARN
    @pusher = MqttClient.new
  end

  def start
    @running = true
    sml = SmlMessage.new
    while @running
      byte = @serialport.getbyte
      if sml.finished?
        @pusher.push(sml.readings, @device_id)
        @logger.debug("dev: #{@device_id}, sml: #{sml}")
        sml = SmlMessage.new
        sleep 5
      else
        sml << byte unless byte.nil?
      end
    end
  end

  def stop
    @running = false
  end
end
