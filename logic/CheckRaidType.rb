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
    end

    def getRaidType
    @@raidTypeArray = `sudo hpacucli ctrl slot=0 pd all show status`
    end
end
#sudo: hpacucli: command not found
test = CheckRaidType.new

puts test.getRaidType
