class Handler
  def initialize
    @handlers = {}
  end

  def handle(event,client)
    if !@handlers[event.type].nil?
			begin
	      @handlers[event.type].each do |k,h|
	        h.call(event,client)
	      end
			rescue
				client.scheduler.queue event.toChannel, 'There was an error in the event handlers: '+$!
			end
    end
  end

  def add(event,&block)
    @handlers[event] = {} if @handlers[event].nil?
		key = block.to_s.hash
    @handlers[event][key] = block
		event.to_s+'.'+key.to_s
  end

	def del(key)
		temp = key.split('.')
		event = temp[0]
		key = temp[1]
		@handlers[event.to_sym].delete(key.to_i)
	end
end
