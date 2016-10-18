#!usr/bin/ruby
#
#Module to check for failed drives on hpacucli servers and partition them if necessary.
#It inherits from the Module superclass.

require "DatamineFstabHandler"

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
 	self.checkFailedDrives
	#unmounting failed drives
        self.umountFailedDrives	
        #turn on LED for failed drives
        self.turnOnFailedDrivesLED
	#waiting for drive replacement confirmation
        self.waitDriveReplace
        
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
       @drivesReplaced = Array.new
       @input = 0
       while @input.to_i > 12 || @input.to_i < 1 do
          print "Once the drive(s) have been replaced please enter their drive numbers separated by commas[enter x to exit]; e.g. 2,6: "
          @input = gets.chomp
	  if @input == "x" then
	     abort("Exiting...")
	  end
       end
       
    end


end


#test = HpacucliModule.new
#test.driveReplacementProcess
