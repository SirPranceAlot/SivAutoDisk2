#!usr/bin/ruby
#
#This class checks if the server is using UUID in fstab and edits fstab if necessary.
#
#

class DatamineFstabHandler
   def initialize
   #creating failed disks using UUID array
   @listOfFailedDisksUsingUUID = Array.new 
   end


     




   #check if fstab is using UUID for failed disks
   def checkIfDiskUseUUID(failedDisks)
      puts "Checking if replaced disks uses UUID in /etc/fstab..."
      File.open("/home/slimvipuwat/SivAutoDisk2/logic/fstab2").each do |line|
         failedDisks.each do |diskNumber|
             if line =~ /\S+ (\/hadoop#{diskNumber})/ then
	        #check if matched disks uses UUID
	        if line =~ /(\w+)=/ then
		   if $1 == "UUID" then
		      puts "Disk #{diskNumber} uses UUID in fstab."
		      @listOfFailedDisksUsingUUID.push(diskNumber)
		   elsif $1 == "LABEL" then
		      puts "Disk #{diskNumber} does not use UUID in fstab."
		   else
		      abort("Cannot detect if replaced disks are using UUID or not. Aborting...")
		   end
		end	
             end
         end
      end
   end 
            
      #device is busy 
end


#test = DatamineFstabHandler.new
#test.umountFailedDrives
