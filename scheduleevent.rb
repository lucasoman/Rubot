class ScheduleEvent
  attr_accessor :time, :command, :repeat, :repeatInterval, :type, :to
  #type: :send, :eval
  def initialize(command,time,type=:send,to=nil,repeat=false,repeatInterval=1)
    @command = command
    @time = time
    @type = type
    @to = to
    @repeat = repeat
    @repeatInterval = repeatInterval
  end
end
