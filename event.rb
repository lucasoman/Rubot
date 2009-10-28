class Event
  # types: :privmsg, :ctcp, :notice, :raw, :join, :part, :kick, :mode, :other
  @@fields = [:body, :toNick, :toChannel, :fromRaw, :fromNick, :fromName, :fromAddress, :type, :raw, :numeric, :mode]
  @@fields.each do |f|
    attr_accessor f
  end

  def initialize(str)
    tokens = str.chop.split(' ')
    @raw = str
    @fromRaw = rmCol(tokens[0])
    if tokens[1].to_i > 0
      rawEvent tokens
    elsif tokens[1].upcase == 'PRIVMSG'
      privmsgEvent tokens
    elsif tokens[1].upcase == 'NOTICE'
      noticeEvent tokens
    elsif tokens[1].upcase == 'JOIN'
      joinEvent tokens
    elsif tokens[1].upcase == 'PART'
      partEvent tokens
    elsif tokens[1].upcase == 'KICK'
      kickEvent tokens
    elsif tokens[1].upcase == 'MODE'
      modeEvent tokens
    else
      otherEvent tokens
    end
  end

  private

  def rmCol(str)
    if str.match(/^:/)
      return str.sub(':','')
    else
      return str
    end
  end

  def rawEvent(tokens)
    @type = :raw
    @fromAddress = rmCol tokens.shift
    @numeric = tokens.shift
    @toNick = tokens.shift
    if tokens.empty?
      @body = ''
    else
      @body = rmCol tokens.join(' ')
    end
  end

  def kickEvent(tokens)
    @type = :kick
    standardEvent tokens
    tokens.shift
    tokens.shift
    @toChannel = tokens.shift
    @toNick = tokens.shift
    @body = rmCol tokens.join(' ')
  end

  def modeEvent(tokens)
    @type = :mode
    standardEvent tokens
    3.times { tokens.shift }
    @mode = tokens.shift
    @body = rmCol tokens.join(' ') unless tokens.empty?
  end

  def privmsgEvent(tokens)
    @type = :privmsg
    standardEvent tokens
  end

  def noticeEvent(tokens)
    @type = :notice
    standardEvent tokens
  end

  def joinEvent(tokens)
    @type = :join
    standardEvent tokens
  end

  def partEvent(tokens)
    @type = :part
    standardEvent tokens
  end

  def standardEvent(tokens)
    from = rmCol tokens.shift
    if from.match(/@/)
      @fromNick = from.split('!')[0]
      @fromName = from.split('!')[1].split('@')[0]
      @fromAddress = from.split('@')[1]
    else
      @fromAddress = from
    end
    tokens.shift
    to = rmCol tokens.shift
    if to.match(/^#/)
      @toChannel = to
    else
      @toNick = to
    end
    @body = rmCol tokens.join(' ') unless tokens.empty?
  end
  
  def otherEvent(tokens)
    @type = :other
  end
end
