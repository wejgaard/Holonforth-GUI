package require Mk4tcl
package require Tk

set dir [file dirname $argv0]
if [namespace exists starkit] {set dir "."}

source $dir/model.tcl
source $dir/view.tcl
source $dir/extview.tcl
source $dir/control.tcl
source $dir/sourceversion.tcl
source $dir/tclforth.tcl

proc CreateStructure {} {
		mk::row append wdb.base mode program  monitor 0  view list		version 001\
			geometry "800x700+50+50" extension fth search textandcode \
			textcolor #ffffff codecolor #ffffff pages 2 comdel \\ \
			runcmd "../tclkit ./main.tcl" syntax Forth safe 0 fontsize 10 bonus 0
		set c [AppendPage type chapter name "Module"]
    		SetBase list $c active $c
    		SetPage $c next ""
    		set s [AppendPage type section name "Section"]
    		SetPage $c list $s active $s
    		SetPage $s next $c
    		set u [AppendPage type unit name "Unit"]
    		SetPage $s list $u active $u
    		SetPage $u next $s
		mk::file commit wdb
}

proc DoTest {} {
	global comp view
	set comp(load) [GetPage [Unit] name]
	SendTarget
}

proc StatusFindReplace {} {
	global color findText replaceText 
	label .s.ftext -text " Find " -bg $color(menu) -font button 
	entry .s.find -textvariable findText -font fixed -width 15
	label .s.rtext -text " Replace " -bg $color(menu) -font button
	entry .s.replace -textvariable replaceText -font fixed -width 15
	pack .s.ftext .s.find .s.rtext .s.replace	-side left 

}

proc ForthCLPanePublic {} {
	global view color fcl
	set view(forthok) .s.forthok
	label $view(forthok) -text " Forth ok>" -bg $color(menu) -font button
	set view(forthcl) .s.forthcl
	entry $view(forthcl) -textvariable fcl(text) -font fixed  -state normal \
		 -width 30
	pack .s.forthcl .s.forthok -side right -expand 1 -fill x
	bind $view(forthcl) <Return> {LoadCommandline; break}
	bind $view(forthcl) <Up> {fcl@-}
	bind $view(forthcl) <Down> {fcl@+}
}

proc StatusBar  {} {
	global color      
	frame .s -bg $color(menu) -relief ridge -bd 1 -padx 0 -pady 0
	StatusFindReplace
	ForthCLPanePublic
	return .s
	
}

proc InitSpecial {} {
	SetRunButton
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
wm minsize . 800 700
catch {console show}
catch {console title "Host console"}

RunHolon  ; # stays here until the user ends the program
CloseDB

