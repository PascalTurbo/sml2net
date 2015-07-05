# Represents one reading
class Reading
  attr_accessor :id, :value, :pushed
  attr_reader :time

  def initialize(params)
    @time = Time.now
    @id = params[:id]
    @value = params[:value]
  end
end
