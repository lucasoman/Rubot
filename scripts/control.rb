class Control
	def handle(event,client)
		unless event.toChannel.nil?
			if event.body.match /^~blah /
			end
		end
	end
	def install#{{{
		$handler.add(:privmsg) do |event,client|
			handle(event,client)
		end
	end#}}}
end
