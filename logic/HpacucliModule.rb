#!usr/bin/ruby
#
#Module to check for failed drives on hpacucli servers and partition them if necessary.
#It inherits from the Module superclass.

require "DatamineFstabHandler"
require "set"

class HpacucliModule < Module

    def initialize
        @failedPhysicalDrives = Array.new
	@failedLogicalDrives = Array.new
	@failedHpFormatDriveNames = Array.new
	@failedHpDriveAndStatus = Hash.new
	@unmountedDrives = Array.new
        @displayOutput = Array.new
        @failedDriveLabels = Array.new
    end

#get a lits of failed drives, cleans the list up a little, gets the drive number, the hp drive number format, and the status message for the drive. Also calls checkFailedLogicalDrives
    def checkFailedDrives
	#----------------------------------------TEST
	#test failed hpacucli failed output file
	File.open("/home/slimvipuwat/SivAutoDisk2/logic/testFailedHpacucli").each do |line|
	    @failedPhysicalDrives.push(line)
	end
	#-------------------------------------------TEST
	#@failedPhysicalDrives = `sudo hpacucli ctrl slot=0 pd all show status`
	@cleanFailedPhysicalDrives = Array.new
	@failedPhysicalDrives.each do |e|
        @cleanFailedPhysicalDrives.push(e.chomp)
        end
	@cleanFailedPhysicalDrives.reject! {|e| e.empty?}
        #clean failedPhysicalDrives array
        @failedPhysicalDrives = Array.new
	#get the failed drive number and status message and store in @failedHpDriveAndStatus
	#get hp failed drive number format and store in @failedHpDriveNames
	#get failed drive numbers and store it in @failedPhysicalDrives array
	@cleanFailedPhysicalDrives.each do |d|
	    if d =~ /\w+ (\S+) \(port 1I:box 1:bay (\d), \S* GB\): (\w+)/
		if $3 == "Failed" || $3 == "Predictive Failure"
		   @failedHpDriveAndStatus[:"#{$2}"] = $3
		   @failedHpFormatDriveNames.push($1)
		   @failedPhysicalDrives.push($2)
	           @failedDriveLabels.push("/hadoop" + $2)
		end
	    end
        end
       #checks logical drives
       self.checkFailedLogicalDrives
    end

#get list of failed logical drives
    def checkFailedLogicalDrives

       @failedLogicalDrives = `sudo hpacucli ctrl slot=0 ld all show status`
       #remove the extra empty lines/spaces
       @cleanFailedLogicalDrives = Array.new
       @failedLogicalDrives.each do |e|
          @cleanFailedLogicalDrives.push(e.chomp)
       end
       @cleanFailedLogicalDrives.reject! {|e| e.empty?}

       #clear FailedLogicalDrives array
       @failedLogicalDrives = Array.new

       #get the failed logical drive numbers
       @cleanFailedLogicalDrives.each do |l|
           if l =~ /\w+ (\d) \(\S+ \S+ \S+ \S+ (\S+)/
	       if $2 == "Failed"
               @failedLogicalDrives.push($1)
	       end	
           end
       end
    end
	
    #display failed drive for use with menu
    def displayFailedDrives
	self.checkFailedDrives
        @failedHpDriveAndStatus.each do |drive, status|
	   @displayOutput.push("Physical Drive: #{drive} Status: #{status}")
	end
	
	@failedLogicalDrives.each do |l|
	   @displayOutput.push("Logical Drive: #{l} Status: Failed")
	end
       return @displayOutput
    end

    #getFailedPhysicalDrives for use with other classes
    def getFailedPhysicalDrives
       self.checkFailedDrives
       return @failedPhysicalDrives
    end

    #getFailedLogicalDrives for use with other classes
    def getFailedLogicalDrives
       self.checkFailedLogicalDrives
       return @failedLogicalDrives
    end

    #turn on LED for failed drives if possible
    def turnOnFailedDrivesLED
       puts "Turning on LED for failed drives..."
       @failedHpFormatDriveNames.each do |l|
          `sudo hpacucli ctrl slot=0 pd #{l.chomp} modify led=on`
       end	   
    end

    #turn off LED for failed drives
    def turnOffFailedDrivesLED
       self.checkFailedDrives
       @failedHpFormatDriveNames.each do |l|
          `sudo hpacucli ctrl slot=0 pd #{l.chomp} modify led=off`
       end
    end

    #start driveReplacementProcess
    def driveReplacementProcess
	#check datamine services
	self.checkServices

 	self.checkFailedDrives
	#unmounting failed drives
        self.umountFailedDrives	
        #turn on LED for failed drives
        self.turnOnFailedDrivesLED
	#waiting for drive replacement confirmation
        self.waitDriveReplace
        #confirm all physical drives are ok
        self.confirmPhysicalDrive
    end

    #unmount failed drives
    def umountFailedDrives
       puts "Unmounting failed drives..."
       dfhlOutput = `df -hl | sort`
       dfhlOutput.each do |f|
          @failedDriveLabels.each do |l|
	      if f =~ /\/\S+\s+\S+\s+\S+\s+\S+\s+\S+ #{l}/ then
		 puts "Unmounted #{l}"
		 `sudo umount #{l}`
	      end
          end
       end
    end

    #waiting for drives to be replaced
    def waitDriveReplace
       puts "Please replace: "
       @failedPhysicalDrives.each {|d| puts "Drive: " + d}
       #array to store the number for the drives replaced
       @drivesReplaced = Set.new
       #true/false to exit loop
       @doneInputtingDrives = false
       while @doneInputtingDrives == false do
          print "Once the drive(s) have been replaced, please enter the drive number of the replaced drive(e.g if you replaced drive 3 then enter 3) [enter x to exit when you're done inputting drive numbers]: "
          @input = gets.chomp
	  #check if number is between 1-12 if so put into @drivesReplaced array
	  if @input.to_i > 12 || @input.to_i < 1 && @input != "x" then
	     puts "Please enter a number between 1-12"
	  elsif @input.to_i < 12 || @input.to_i > 0
	     @drivesReplaced.add(@input.to_i)
 	  end

          #exit loop
	  if @input == "x" then
	     @doneInputtingDrives = true
	     @drivesReplaced.delete(0)
	  end
       end
     end


     #makes sure all physical drives are "OK"
     def confirmPhysicalDrive
	puts "Confirming all physical drives are OK..."
	physicalDrivesList = Array.new
        physicalDrivesList = `sudo hpacucli ctrl slot=0 pd all show status`	
	cleanPhysicalDrivesList = Array.new
	physicalDiskStatuses = Array.new
        #puts a clean list in cleanPhysicalDrivesList without \n
	physicalDrivesList.each do |d|
 	   cleanPhysicalDrivesList.push(d.chomp)
	end
	#remove empty strings in cleanPhysicalDrivesList
	cleanPhysicalDrivesList.reject! {|e| e.empty?}
	#adds any failed or predictivefailure disks in the @physicalDiskStatuses array
        cleanPhysicalDrivesList.each do |c|
	   if c =~ /\w+ (\S+) \(port 1I:box 1:bay (\d), \S* GB\): (\w+)/ then
	      if $3 == "Failed" || $3 == "Predictive Failure" then
		 physicalDiskStatuses.add("Drive #{$2} status not OK")
	      end
	   end
	end
	#if @physicalDiskStatuses is empty then all physical disks are ok
	if physicalDiskStatuses.empty?  then
	    puts "All physical drive statuses are OK!"
	else
	#if not, abort program
	    puts physicalDiskStatuses
            abort("Not all drive statuses are OK, aborting... please rerun script as needed.")

	end
     end

     #check if datamine services are on
     def checkServices
	puts "Checking datamine services..."
	#check datanode status
	datanodeStatus = `sudo service datanode status`
	datanodeStatus.chomp
	#ask to continue if service is started else abort
	if datanodeStatus =~ /(\S+) \S+ \S+ \S+ \S+ STARTED/
	   puts "#{$1} service status is running, do you want to continue? y/n"
	   input = gets
	   input.chomp.downcase
	   if input != "y" then
	   abort("Aborting...")
	   end
	end

	#check tasktracker status
	tasktrackerStatus = `sudo service tasktracker status`
	tasktrackerStatus.chomp
	#ask to continue if service is started else abort
	if tasktrackerStatus =~ /(\S+) \S+ \S+ \S+ \S+ STARTED/ then
	   puts "#{$1} service status is running, do you want to continue? y/n"
	   input = gets
	   input.chomp.downcase
	   if input != "y" then
	   abort("Aborting...")
	   end
	
	end
     end
end

#test = HpacucliModule.new
#test.driveReplacementProcess
