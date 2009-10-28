class Sandbox
	def initialize#{{{
		options = $config.get('sandbox')
		@timeout = options['timeout'].nil? ? 2 : options['timeout']
	end#}}}
	def __process(str,client)#{{{
		error = sane? str
		return error unless error.nil?
		thread = Thread.new(str) do |string|
			begin
				val = eval(string)
			rescue SyntaxError
				val = "I understand Ruby code, not whatever that is."
			rescue
				val = "I can't do that for some reason."
			end
			val
		end
		thread.join(@timeout)
		if thread.alive?
			Thread.kill(thread)
			msg = "You trying to kill me?"
		else
			msg = thread.value
		end
		msg
	end#}}}
	def sane?(str)#{{{
		badMatches = [
			/\$/, # no globals
			/def /, # no function overrides
			/eval/, # no eval() calls
			/`/, # no shell commands
			/exec/, # no shell commands
			/exit/, # no exiting!
			/syscall/, # no shell commands
			/system/, # no shell commands
			/File/ # no file IO
			]
		badMatches.each do |re|
			return "Naughty, naughty boy." if str.match(re)
		end
		return nil
	end#}}}
	def method_missing(meth)#{{{
		"You're talking gibberish."
	end#}}}
	def sendAction(str)#{{{
		@client.sendAction(@to,str)
	end#}}}
	def silent#{{{
		@silent = true
	end#}}}
	def handler#{{{
		$handler
	end#}}}
	def handle(event,client)#{{{
		unless event.toChannel.nil?
			if event.body.match /^~e /
				@client = client
				@to = event.toChannel
				temp = event.body.split(' ')
				temp.shift
				msg = self.__process temp.join(' '), client
				@_ = msg
				client.scheduler.queue event.toChannel, msg.nil? ? "(nil)" : msg.to_s unless @silent
				@silent = false
			end
		end
	end#}}}
	def install#{{{
		$handler.add(:privmsg) do |event,client|
			handle(event,client)
		end
	end#}}}
end

