class Bf
	def initialize#{{{
		clearCells
		options = $config.get('bfinterpreter')
		@timeout = options['timeout'].nil? ? 2 : options['timeout']
	end#}}}
	def interpret(bfstring)#{{{
		thread = Thread.new(bfstring) do |string|
			begin
				val = _interpret(string)
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
	def _interpret(bfstring)#{{{
		return 'Malformed!' if !sane(bfstring)
		returnstring = ''
		loopstack = []
		codeposition = 0
		codelength = bfstring.size
		loopjumpto = nil
		jumping = false
		jumpcount = 0
		while codeposition < codelength
			char = bfstring[codeposition].chr
			if jumping
				case char
					when '['
						jumpcount += 1
					when ']'
						jumpcount -= 1
						jumping = false if jumpcount == 0
				end
			else
				case char
					when '['
						if @cells[@pointer] == 0
							if loopjumpto.nil?
								jumpcount += 1
								jumping = true
							else
								codeposition = loopjumpto
								loopjumpto = nil
							end
						else
							loopstack.push codeposition
						end
					when ']'
						loopjumpto = codeposition
						codeposition = loopstack.pop
						next
					when '>'
						@pointer += 1
						@cells[@pointer] = 0 if @cells[@pointer].nil?
					when '<'
						@pointer -= 1
						@cells[@pointer] = 0 if @cells[@pointer].nil?
					when '+'
						@cells[@pointer] += 1
						@cells[@pointer] = @cells[@pointer] % 256
					when '-'
						@cells[@pointer] -= 1
						@cells[@pointer] = 0 if @cells[@pointer] < 0
					when '.'
						if @cells[@pointer] < 32 || @cells[@pointer] > 127
							returnstring += '\x'+toHex(@cells[@pointer])
						else
							returnstring += @cells[@pointer].chr
						end
					when '#'
						returnstring += dump
					when '*'
						clearCells
				end
			end
			codeposition += 1
		end
		returnstring
	end#}}}
	def dump#{{{
		dumpstring = ''
		cellcount = 0
		total = @cells.size
		i = 0
		while cellcount < total
			if i == @pointer
				dumpstring += '>'
			else
				dumpstring += '|'
			end
			if @cells[i].nil?
				dumpstring += '00'
			else
				dumpstring += toHex(@cells[i])
				cellcount += 1
			end
			i += 1
		end
		'('+dumpstring+')'
	end#}}}
	def toHex(decnum)#{{{
		letters = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F)
		second = decnum % 16
		first = (decnum - second) / 16
		letters[first].to_s+letters[second].to_s
	end#}}}
	def sane(bfstring)#{{{
		total = bfstring.size
		codeposition = 0
		loopcount = 0
		while codeposition < total
			case bfstring[codeposition].chr
				when '['
					loopcount += 1
				when ']'
					loopcount -= 1
					return false if loopcount < 0
			end
			codeposition += 1
		end
		return (loopcount == 0)
	end#}}}
	def clearCells#{{{
		@cells = [0]
		@pointer = 0
	end#}}}
end

class BfInterpreter
	def initialize#{{{
		@bfs = {}
	end#}}}
	def handle(event,client)#{{{
		if !event.toChannel.nil? && event.body.match(/^~bf /)
			@bfs[event.fromNick] = Bf.new if @bfs[event.fromNick].nil?
			message = @bfs[event.fromNick].interpret(event.body).sub(/\r/,'\r').sub(/\n/,'\n')
			client.scheduler.queue event.toChannel, message unless message.nil? || message == ''
		end
	end#}}}
	def install#{{{
		$handler.add(:privmsg) do |event,client|
			handle(event,client)
		end
	end#}}}
end

