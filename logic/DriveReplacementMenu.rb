#!usr/bin/ruby
#
#importing required classes
require "CheckRaidType"
require "InfoGatherer"

class DriveReplacementMenu

    #display menu method
    def displayMenu
    #initializing objects
    checkRaidType = CheckRaidType.new
    info  = InfoGatherer.new

    puts "~~SivAutoDisk 2~~\n\n"
    puts "This script is for automating disk replacements."
    puts "Hostname: " + info.getHostName
    puts "Disk(s) detected requiring repair:"
    puts "System type: " + info.getSystemType
    puts "Raid type: " + checkRaidType.getRaidType
    end
end
