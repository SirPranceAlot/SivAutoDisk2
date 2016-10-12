#!usr/bin/ruby
#
#Module to check for failed drives on hpacucli servers and partition them if necessary.
#It inherits from the Module superclass.


class HpacucliModule < Module

    def initialize
        @failedPhysicalDrives = Array.new
	@failedLogicalDrives = Array.new
	@unmountedDrives = Array.new
    end

    def checkFailedPhysicalDrives
	@failedPhysicalDrives = `sudo hpacucli ctrl slot=0 pd all show status`
	@cleanFailedPhysicalDrives = Array.new
	@failedPhysicalDrives.each do |e|
            @cleanFailedPhysicalDrives.push(e.chomp)
         end
	@cleanFailedPhysicalDrives.reject! {|e| e.empty?}
	puts @cleanFailedPhysicalDrives
	#\w+ (\S+) \(port 1I:box 1:bay (\d), \S* GB\): (\w+)
    end


end


test = HpacucliModule.new

test.checkFailedPhysicalDrives
