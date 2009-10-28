toInstall = [
Sandbox.new,
BfInterpreter.new,
Dictionary.new,
Logger.new,
#Pager.new,
]

toInstall.each do |addon|
	addon.install
end
