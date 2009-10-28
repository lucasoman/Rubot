class Client < TCPSocket
  attr_accessor :nick, :scheduler, :server, :port, :nick, :altNick, :user, :address, :fullName, :scheduleInterval, :autoJoins
  def initialize(server,port,nick,altNick,user,address,fullName,scheduleInterval,autoJoins)
    super server,port
    send "NICK "+nick.to_s+"\n"
    send "USER "+nick.to_s+" "+user.to_s+" "+address.to_s+" :"+fullName.to_s+"\n"
    @server = server
    @port = port
    @nick = nick
    @altNick = altNick
    @user = user
    @address = address
    @fullName = fullName
		@scheduleInterval = scheduleInterval
    @scheduler = Scheduler.new(scheduleInterval,self)
		@autoJoins = autoJoins
		@joined = false
  end

  def handle(str)
		unless str.nil?
	    tokens = str.split(' ')
	    if str.match(/^PING/)
	      tokens.shift
	      send "PONG "+tokens.join(' ')+"\n"
				if !@joined
					@joined = true;
					@autoJoins.each do |c|
						send 'JOIN '+c.to_s
					end
				end
	    else
	      $handler.handle(Event.new(str),self)
	    end
		end
  end

  def sendMessage(to,str)
    send 'PRIVMSG '+to+' :'+str
  end

  def sendAction(to,str)
    send 'PRIVMSG '+to+' :'+1.chr+'ACTION '+str+1.chr
  end

  def sendNotice(str,to)
  end

  def doEvents
    events = @scheduler.nextScheduleEvents
    events.each do |e|
      if e.type == :send
        sendMessage e.to,e.command
      elsif e.type == :eval
        eval(e.command)
      end
    end
  end

  private

  def send(str)
    write str+"\n"
    $stderr.puts 'SENT: '+str
  end
end
