class Scheduler
  def initialize(interval,client)
    @client = client
    @interval = interval
    @schedule = []
    @queue = []
    @lastTime = 0
  end

  def queue(to,msg)
    @queue.push ScheduleEvent.new(msg,Time.now.to_i,:send,to)
  end

  def nextScheduleEvents
    events = []
		now = Time.now.to_i
    return events unless((now % @interval) == 0)
    @lastTime = now
    @schedule.each do |e|
      if e.time >= now
        events.push e
        if e.repeat
          e.time += e.interval
        end
      end
    end
    events.each do |e|
      @schedule.delete e unless e.repeat
    end
    unless @queue.size == 0
      events.push @queue.shift
    end
    events
  end

  def addScheduleEvent(event)
    @schedule.push event
  end
end
