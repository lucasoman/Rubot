class Logger
	def handle(event,client)#{{{
		logfile = File.new('logfile.txt','a')
		message = (event.toNick.nil? ? event.toChannel : event.toNick)+': <'+event.fromNick+'> '+event.body+"\n"
		logfile.write message
		logfile.close
	end#}}}
	def install#{{{
		$handler.add(:privmsg) do |event,client|
			handle(event,client)
		end
	end#}}}
end

