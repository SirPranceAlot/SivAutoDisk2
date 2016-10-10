#!usr/bin/ruby
#
#
#This is part of SivAutoDisk2. This script is for gathering system info. 

=begin
InfoGatherer class gathers system information to be used for the script.
=end
class InfoGatherer
    
    def initialize()
        @@hostname = `hostname`
    end


    def getHostName
        puts "#{@@hostname}"
    end
end

d = InfoGatherer.new

d.getHostName

