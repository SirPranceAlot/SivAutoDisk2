#!usr/bin/ruby
#
#This class checks if the server is using UUID in fstab and edits fstab if necessary.
#
#
require "InfoGatherer"

class DatamineFstabHandler
   def initialize
   #instantiate infogatherer object
   @info = InfoGatherer.new
  
   #creating array to store failed drive in hadoop lable format i.g. /hadoop1,/hadoop2,etci
   @failedDriveHadoopLabels = Array.new
   @info.getFailedDrives.each do |d|
      @failedDriveHadoopLabels.push("/hadoop" + d)
   end


   #creating failed disks using UUID array
   @listOfFailedDisksUsingUUID = Array.new
     
   end




   #check if fstab is using UUID for failed disks returns true/false
   def checkIfFstabUseUUID(failedDisks)
      File.open("/etc/fstab").each do |line|
         @failedDriveHadoopLabels.each do |label|
             if line =~ /(\w+)=\S+ (\S+)/ && $1 == "UUID" && $2 == label then
                @listOfFailedDisksUsingUUID.push($2)
             end
         end
      end
      #checking if any disks uses UUID
      if @listOfFailedDisksUsingUUID.length > 0 then
	 return true
      else
	 return false
      end
      
   end
=begin
   #check if failed drives are unmounted, if not unmount drives
   def umountFailedDrives
      puts "Unmounting Failed Drives"
      @info.getFailedDrives.each {|d| puts "Disk: #{d}"} 
      
      dfHlOutput = Array.new
      dfHlOutput = `df -hl`
      @failedDriveHadoopLabels.each do |x|
          dfHlOutput.each do |o|
              if o =~ /\/\S+\s+\S+\s+\S+\s+\S+\s+\S+ #{x}/
		 umountOutput = `sudo umount #{x}`
		 umountOutput.each do |u| 
                    if u =~ /\S+ \S+ (device is busy.)/
                        abort("#{x} is busy aborting, please confirm disk is not in use.")
		    end
		 end
              end
          end
      end      
=end
    
            
      #device is busy 
end


#test = DatamineFstabHandler.new
#test.umountFailedDrives
