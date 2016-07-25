package require Tk

set mfile holon.mon

set mlasttime 0

proc MLast {} {
	global mfile
	if {[file exists $mfile]} {
		file stat $mfile status
		return $status(mtime)
	} {
		return 0
	}
}

proc MEval {} {
	global mfile
	puts [uplevel #0 {eval {source $mfile}}]
}

proc Monitor {} {
	global mlasttime errorInfo
	if {$mlasttime != [MLast]} {
		set mlasttime [MLast]
		if {[catch MEval result]} {
			puts "Error: $errorInfo"
		}
	}
	after 200 Monitor
}

set mlasttime [MLast]
Monitor

# StartMonitor
# console show
source chess.tcl

