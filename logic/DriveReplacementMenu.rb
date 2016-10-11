#!usr/bin/ruby
#
#declaring required classes
require "CheckRaidType"
require "InfoGatherer"

class DriveReplacementMenu
#initializing classes to variables
checkRaidType = CheckRaidType.new
info  = InfoGatherer.new

puts "~~SivAutoDisk 2~~\n\n"
puts "This script is for automating disk replacements."
puts "Hostname: " + info.getHostName
puts "Disk(s) detected requiring repair:"
puts "System type:"
puts "Raid type: " + checkRaidType.getRaidType
end

