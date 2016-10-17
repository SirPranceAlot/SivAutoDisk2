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
   puts @failedDriveHadoopLabels
   end

   #check if fstab is using UUID for failed disks
   def checkIfFstabUseUUID(failedDisks)
      File.open("fstab").each do |line|
         puts line
      end
   end

end

test = DatamineFstabHandler.new
test.checkIfFstabUseUUID(@failedDriveHadoopLabels)

