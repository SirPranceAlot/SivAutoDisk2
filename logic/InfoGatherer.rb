#!usr/bin/ruby
#
#
#This is part of SivAutoDisk2. This script is for gathering system info. 

class InfoGatherer
    
    def initialize()
        @@hostname = `hostname`
	@@systemType = `sudo dmidecode -t system | grep -i "product name"`
    end


    def getHostName
        return @@hostname
    end
    
    #the @@systemType string will contain "    Product Name: [systemtype]" this removes the "Product Name: "
    #so we're left with the [systemtype]
    def getSystemType
	@@systemType = @@systemType.strip.chomp.gsub(/Product Name: /,"")	
	return @@systemType
    end
end



