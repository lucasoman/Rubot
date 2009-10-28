require 'rexml/document'
require 'net/http'

class Dictionary
	def define(word)#{{{
		definition = ''
		begin
			response = Net::HTTP.get('services.aonaware.com','/DictService/DictService.asmx/DefineInDict?dictId=gcide&word='+word.to_s)
			doc = REXML::Document.new(response)
			definition = REXML::XPath.first(doc,'/WordDefinition/Definitions/Definition/WordDefinition').text
		rescue
			definition = "I can't seem to find a definition for that word."
		end
		definition
	end#}}}
	def element(word)#{{{
		definition = ''
		begin
			response = Net::HTTP.get('services.aonaware.com','/DictService/DictService.asmx/DefineInDict?dictId=elements&word='+word.to_s)
			doc = REXML::Document.new(response)
			definition = REXML::XPath.first(doc,'/WordDefinition/Definitions/Definition/WordDefinition').text
		rescue
			definition = "I can't seem to find that element."
		end
		definition
	end#}}}
	def thesaurus(word)#{{{
		synonyms = ''
		begin
			response = Net::HTTP.get('services.aonaware.com','/DictService/DictService.asmx/DefineInDict?dictId=moby-thes&word='+word.to_s)
			doc = REXML::Document.new(response)
			definition = REXML::XPath.first(doc,'/WordDefinition/Definitions/Definition/WordDefinition').text
		rescue
			definition = "I can't seem to find any synonyms for that word."
		end
		definition
	end#}}}
	def spell(word)#{{{
		spellings = ''
		begin
			response = Net::HTTP.get('services.aonaware.com','/DictService/DictService.asmx/Match?word='+word.to_s+'&strategy=lev')
			doc = REXML::Document.new(response)
			words = []
			REXML::XPath.each(doc,'/ArrayOfDictionaryWord/DictionaryWord/Word') do |wordEle|
				words.push wordEle.text
			end
			spellings = words.collect{|w| w.downcase}.uniq.join(', ')
		rescue
			spellings = "I can't seem to find any matching words."
		end
		spellings = "I can't seem to find any matching words." if spellings == ''
		spellings
	end#}}}
	def handle(event,client)#{{{
		unless event.toChannel.nil?
			if event.body.match /^~define /
				response = define(event.body.split(' ')[1])
				response = response.split("\n\n").join("\n")
				i = 0;
			  response.split("\n").each do |line|
					break if i > 7
					client.scheduler.queue event.toChannel, line
					i += 1
				end
			elsif event.body.match /^~thesaurus /
				response = thesaurus(event.body.split(' ')[1])
				unless response.index(':').nil?
					response = response.split("\n").join('').split(':')[1].split(', ')[0,25].join(', ').sub(/^\s*/,'')
				end
				client.scheduler.queue event.toChannel, response
			elsif event.body.match /^~element /
				response = element(event.body.split(' ')[1])
				client.scheduler.queue event.toChannel, response.split("\n").join(' ')
			elsif event.body.match /^~spell /
				response = spell(event.body.split(' ')[1])
				client.scheduler.queue event.toChannel, response
			end
		end
	end#}}}
	def install#{{{
		$handler.add(:privmsg) do |event,client|
			handle(event,client)
		end
	end#}}}
end

