require 'logger'
require 'rubyserial'
require_relative 'sml_message'

# SML Reader
class SmlReader
  def initialize(params)
    @device = params[:device]
    @serialport = Serial.new @device, 9600
    @running = false
    @logger = Logger.new("sml_reader.log")
  end

  def start
    @running = true
    sml = SmlMessage.new
    while @running
      byte = @serialport.getbyte
      if sml.finished?
        # sml.readings.each do |r|
        #   pusher.push(r)
        # end
        @logger.info("dev: #{@device}, sml: #{sml.to_s}")
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
