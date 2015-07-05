require 'logger'
require 'rubyserial'
require_relative 'sml/sml_message'
require_relative '../net_pusher'

# SML Reader
class SmlReader
  def initialize(params)
    @device = params[:device]
    @serialport = Serial.new @device, 9600
    @running = false
    @logger = Logger.new('sml_reader.log')
    @pusher = NetPusher.new
  end

  def start
    @running = true
    sml = SmlMessage.new
    while @running
      byte = @serialport.getbyte
      if sml.finished?
        @net_pusher.push(sml.readings)
        @logger.debug("dev: #{@device}, sml: #{sml}")
        sml = SmlMessage.new
      else
        sml << byte unless byte.nil?
      end
    end
  end

  def stop
    @running = false
  end
end
