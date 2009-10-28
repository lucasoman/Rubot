class Config
  require 'yaml'

  def initialize
    loadDoc
  end

  def getServers
    @doc['servers']
  end

  def getOptions
    @doc['options']
  end

  def get(name)
    return @doc[name] unless @doc[name].nil?
    return nil
  end

  def loadDoc
    @doc = YAML::load(File.open('config.yml'))
  end
end
