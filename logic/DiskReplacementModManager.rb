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
     @@cleanAvailableModules = Array.new 
     @@availableModules = `ls | grep Module`
     @@availableModules.each do |m|
     #removes "Module.rb" from availableModules array and put new values in clean array
     @@cleanAvailableModules.push(m.chomp.gsub(/Module.rb/,"").downcase)
     #removes empty values
     @@cleanAvailableModules.reject! {|e| e.empty?}
     end
     puts @@cleanAvailableModules
   end
   
   #checks if there is a module available for the raid type
   def checkModuleAvailable
   @@cleanAvailableModules.each do |m|
   if m.chomp.eql? @@raidType.getRaidType
   #will put code to use the module here
   end
   end
   end

end

test = DiskReplacementModManager.new

test.checkModuleAvailable


