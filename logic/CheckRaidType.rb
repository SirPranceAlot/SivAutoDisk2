#!usr/bin/ruby
#
#
#This script is part of SivAutoDisk2 and checks the raid type of the system.
#
#Version 1.0 
#


class CheckRaidType
    def initialize()
    @@raidTypeArray = Array.new
    @@cleanRaidTypeArray = Array.new
    end


#get raid type

    def getRaidType
    #tries hpacucli command and cleans the output of leading/trailing whitelines
    #and empty elements
    @@raidTypeArray = `sudo hpacucli ctrl slot=0 pd all show status`
    @@raidTypeArray.each do |i|
    @@cleanRaidTypeArray.push(i.strip)
    @@cleanRaidTypeArray.delete_if { |x| x.empty? }
    end
    #check if raid type is HP (right now it only checks for HP later
    #checks for different raid type will be added in the future)
    puts @@cleanRaidTypeArray.length
    end


end




#sudo: hpacucli: command not found
test = CheckRaidType.new
test.getRaidType
