#!usr/bin/ruby
#
#Module to check for failed drives on hpacucli servers and partition them if necessary.
#It inherits from the Module superclass.


class HpacucliModule < Module

    def initialize
        @failedPhysicalDrives = Array.new
	@failedLogicalDrives = Array.new
	@failedHpDriveNames = Array.new
	@failedHpDriveAndStatus = Hash.new
	@unmountedDrives = Array.new
    end

#get a lits of failed drives, cleans the list up a little, gets the drive number, the hp drive number format, and the status message for the drive
    def checkFailedPhysicalDrives
	@failedPhysicalDrives = `sudo hpacucli ctrl slot=0 pd all show status`
	@cleanFailedPhysicalDrives = Array.new
	@failedPhysicalDrives.each do |e|
            @cleanFailedPhysicalDrives.push(e.chomp)
        end

	@cleanFailedPhysicalDrives.reject! {|e| e.empty?}


	#get the failed drive number and status message and store in @failedHpDriveAndStatus
	#get hp failed drive number format and store in @failedHpDriveNames
	@cleanFailedPhysicalDrives.each do |d|
	    if d =~ /\w+ (\S+) \(port 1I:box 1:bay (\d), \S* GB\): (\w+)/
		if $3 == "Failed" || $3 == "Predictive Failure"
		   @failedHpDriveAndStatus[:"#{$2}"] = $3
		   @failedHpDriveNames.push($1)
		end
	    end
        end
	puts @failedHpDriveAndStatus
	puts @failedHpDriveNames	
    end


end


test = HpacucliModule.new

test.checkFailedPhysicalDrives
