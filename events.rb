$handler.add(:privmsg) do |event,client|
  $stderr.puts event.fromNick+': '+event.body
end

$handler.add(:raw) do |event,client|
  $stderr.puts event.fromAddress+': ('+event.numeric+') '+event.body
end

$handler.add(:join) do |event,client|
  $stderr.puts '* '+event.fromNick+' has joined '+event.toChannel
end

$handler.add(:kick) do |event,client|
  $stderr.puts '* '+event.fromNick+' has kicked '+event.toNick+' from '+event.toChannel
end

$handler.add(:part) do |event,client|
  $stderr.puts '* '+event.fromNick+' has parted from '+event.toChannel
end

$handler.add(:other) do |event,client|
  $stderr.puts 'OTHER EVENT: '+event.raw
end
