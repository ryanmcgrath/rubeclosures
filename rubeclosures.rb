require 'rexml/document'
require 'open-uri'
include REXML

# A simple wrapper for the foreclosurelistings.com API.
# Pull down the 10 most recent foreclosures for a given area,
# or check if a given address is actually in foreclosure or not.

# Author: Ryan McGrath (ryan [at] venodesigns dot net) (@ryanmcgrath on Twitter)

class Rubeclosures
	def initialize(domain, api_key)
		@domain = domain
		@api_key = api_key
		@recent_url = "http://api.foreclosurelistings.com/foreclosure?domain=" + @domain + "&key=" + @api_key
		@is_foreclosure_url = "http://api.foreclosurelistings.com/isforeclosure?domain=" + @domain + "&key=" + @api_key
	end

	def getRecent(options = {})
		# Using blank defaults, because I'm not that concerned about it at the moment
		areas = {
			:state => nil,
			:county => nil,
			:city => nil,
			:zipcode => nil
		}.merge options

        # Exactly what you think it is. ;D
		call_url = @recent_url

		areas.each { |key, value|
			if !value.nil? 
				call_url += "&#{key}=#{value}"
			end
		}

        return createObjFromXML(call_url)
    end

    def check(address, city, state)
        call_url = @is_foreclosure_url + "&address=#{address}&city=#{city}&state=#{state}"
        return createObjFromXML(call_url)
    end

    def createObjFromXML(call_url)
        return_results = Array.new

        file = open(call_url).read()
        doc = Document.new file

        doc.elements.each("foreclosures/listing") do |element| 
            listing_obj = { }

            element.each do |prop|
                if prop.class == REXML::Element
                    listing_obj[prop.name] = prop.text
                end
            end

            return_results << listing_obj
        end

        return return_results
    end
end	
