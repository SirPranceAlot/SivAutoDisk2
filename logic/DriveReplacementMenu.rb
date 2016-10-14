#!usr/bin/ruby
#
#importing required classes
require "InfoGatherer"

class DriveReplacementMenu

    #display menu method
    def displayMenu
    #initializing objects
    info  = InfoGatherer.new

    puts "~~SivAutoDisk 2~~\n\n"
    puts "This script is for automating disk replacements."
    puts "Hostname: " + info.getHostName
    puts "Disk(s) status : "  
    info.getFailedDrives
    puts "System type: " + info.getSystemType
    puts "Raid type: " + info.getRaidType
    end
end

#test = DriveReplacementMenu.new
#test.displayMenu
