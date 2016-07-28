package require Mk4tcl
package require Tk

set dir [file dirname $argv0]
if [namespace exists starkit] {set dir "."}

source $dir/model.tcl
source $dir/view.tcl
source $dir/extview.tcl
source $dir/control.tcl
source $dir/sourceversion.tcl

set RightButton Button-3   ;# Windows and Linux
if {$tcl_platform(os)=="Darwin"} {set RightButton Button-2}

if {$tcl_platform(os)=="Linux"} {tk scaling 1.2}

set mfile $dir/holon.mon

proc Last {} {
	global mfile
	if {[file exists $mfile]} {
		file stat $mfile status
		return $status(mtime)
	} {
		return 0
	}
}

proc DoIt {} {
	global mfile
	puts [uplevel #0 {eval {source $mfile}}]
}

set mlast 0

proc Monitor {} {
	global mlast errorInfo
	if {$mlast != [Last]} {
		set mlast [Last]
		if {[catch DoIt result]} {
			puts "Error: $errorInfo"
		}
	}
	after 200 Monitor
}

proc StartMonitor {} {
	global mlast
	set mlast [Last]
	Monitor
}

proc LoadUnit {} {
	global view 
	if [NoUnits] return
	set loadText ""
	if [Editing] {
		set marked [$view(code) tag ranges sel]
		if {$marked!=""} {
			set loadText [eval {$view(code) get} $marked ]
		} {	
			SaveIt
		}
	}
	if {$loadText==""} {set loadText [GetPage [Unit] source]}
	set f [open $::sourcedir/holon.mon w]
	fconfigure $f -encoding binary
	puts $f "$loadText\n"
	close $f
}

if [namespace exists starkit] {cd ../..}
set sysdir [pwd]
file mkdir $sysdir/source/
# file mkdir $sysdir/backup/
set sourcedir "$sysdir/source/"

OpenDB
if {[GetBase monitor]} {StartMonitor}
set setup(search) [GetBase search]                              
if {[GetBase syntax]==""} {SetBase syntax Tcl}
if {[GetBase safe]==""} {SetBase safe 1}
if {[GetBase fontsize]==""} {SetBase fontsize 10}
set version [GetBase version]
SetBase bonus 0

wm title . "[string toupper $appname 0 0]"   
wm geometry . [GetBase geometry]  
if {[Book]} {wm minsize . 650 600} {wm minsize . 800 700}

WriteAllChapters
RunHolon  ; # stays here until the user ends the program
CloseDB

