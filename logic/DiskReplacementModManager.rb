#!usr/bin/ruby
#
#This class determines which disk replacement module to use.
#Every module has to be named in this format [modulename]Module ex. HpacucliModule.rb, MegacliModule.rb, etc.

#importing CheckRaidType class
require "CheckRaidType"


class DiskReplacementModManager

   #instantiating CheckRaidType to raidType object
   @@raidType = CheckRaidType.new
   

   #initialize object and gets a list of available modules, the module has to match the naming format stated
   #above
   def initialize
     @@availableModules = Array.new 
     @@availableModules = `ls | grep Module`
     puts @@availableModules
   end
   
   #checks if there is a module available for the raid type
   def checkModuleAvailable
   @@availableModules.each do |m|
   if m.chomp.eql? @@raidType.getRaidType
   puts "ok"
   end
   end
   end

end

test = DiskReplacementModManager.new

test.checkModuleAvailable


