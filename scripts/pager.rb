class Pager
	require 'net/smtp'
	def handle(event,client)#{{{
		unless event.toChannel.nil?
			if event.body.match /lucas/
				Net::SMTP.start('mail.lucasoman.com',25,'lucasoman.com','me@lucasoman.com','sthlyg35',:login) do |smtp|
					smtp.send_message 'check IRC', 'me@lucasoman.com', '9126559594@vtext.com'
				end
			end
		end
	end#}}}
	def install#{{{
		$handler.add(:privmsg) do |event,client|
#			handle(event,client)
		end
	end#}}}
end
