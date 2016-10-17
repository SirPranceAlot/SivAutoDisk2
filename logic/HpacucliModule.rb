#!usr/bin/ruby
#
#Module to check for failed drives on hpacucli servers and partition them if necessary.
#It inherits from the Module superclass.

class HpacucliModule < Module

    def initialize
        @failedPhysicalDrives = Array.new
	@failedLogicalDrives = Array.new
	@failedHpFormatDriveNames = Array.new
	@failedHpDriveAndStatus = Hash.new
	@unmountedDrives = Array.new
        @displayOutput = Array.new
    end

#get a lits of failed drives, cleans the list up a little, gets the drive number, the hp drive number format, and the status message for the drive. Also calls checkFailedLogicalDrives
    def checkFailedDrives
	@failedPhysicalDrives = `sudo hpacucli ctrl slot=0 pd all show status`
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
end


#test = HpacucliModule.new
#test.displayFailedDrives
#puts test.getFailedPhysicalDrives
#puts test.getFailedLogicalDrives
