class QueueEvent
  attr_accessor :time, :string, :repeat, :repeatInterval
  def initialize(string,time,repeat=false,repeatInterval=1)
    @string = string
    @time = time
    @repeat = repeat
    @repeatInterval = repeatInterval
  end
end
