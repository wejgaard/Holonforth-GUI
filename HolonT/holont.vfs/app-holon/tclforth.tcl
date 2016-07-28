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

if ![info exists holonkit] StartMonitor

set fcl(history) {}
set fcl(index) 0
set fcl(text) ""

proc fcl! {} {
	global fcl
	if {$fcl(text)==""} return
	lappend fcl(history) $fcl(text) 
	set fcl(index) [llength $fcl(history)]
	set fcl(text) ""
}

proc fcl@- {} {
	global fcl
	if {$fcl(index)>0} {incr fcl(index) -1}
	set fcl(text) [lindex $fcl(history) $fcl(index)]
}

proc fcl@+ {} {
	global fcl
	incr fcl(index)
	if {$fcl(index)>=[llength $fcl(history)]} {
		set fcl(text) ""
		set fcl(index) [llength $fcl(history)]
	} {
		set fcl(text) [lindex $fcl(history) $fcl(index)]
	}
}

proc Load&SendCode {source} {
	global definer comp view locals 
#	if [Editing] {SaveIt}
	array unset locals
	set comp(code) {}
	set comp(objtype) {}
	set comp(message) {}
	set comp(source) [string trim $source]
	set comp(imax) [string length $comp(source)]
	set comp(i) 0	
	GetItem
	CompileColon
	ShowCompCode
	set comp(load) "$comp(code)\n\n"
	SendTarget
}

proc LoadCommandline {} {
	global fcl
	Load&SendCode $fcl(text)
	fcl!
}

proc LoadTestcode {} {
	global view
	Load&SendCode [$view(test) get 1.0 "end -1c"]
}

set comp(source) {}  ;# Der Source der Unit
set comp(code) {}    ;# Der erzeugte Tclcode
set comp(word) {}    ;# aktuelles Word
set comp(i) 0        ;# index in source text
set comp(imax) 0     ;# end index of source text
set comp(in) {}      ;# input parameter tcl code
set comp(out) {}     ;# output parameter tcl code

proc GetSource {} {
	global comp
	set comp(source) [GetPage [Unit] source]
	set comp(imax) [string length $comp(source)]
	set comp(i) 0
}

proc char {a} {
	format %c $a
}

proc ascii {c} {
	binary scan $c "c" a
	return $a
}

proc GetAscii {i} {
	global comp
	ascii [string index $comp(source) $i]
}

proc wSkip {} {
	global comp
	while {[GetAscii $comp(i)]<33} {
		incr comp(i)
		if {$comp(i)>=$comp(imax)} {break}
	}
}

proc wScan {} {
	global comp 
	set t1 $comp(i); set t2 $t1
	while {[GetAscii $comp(i)]>32} {
		set t2 $comp(i); incr comp(i)
		if {$comp(i)>=$comp(imax)} {break}
	}
	set comp(word) [string range $comp(source) $t1 $t2]
}

proc GetItem {} {
	global comp
	if {$comp(i)>=$comp(imax)} {set comp(word) "" ; return $comp(word)}
	wSkip; wScan
	if {$comp(word)=="."} {set comp(word) .t}
	return $comp(word)
}

proc FirstItem? {} {
	global comp
	expr {[string length $comp(word)]==$comp(i)}
}

proc PushText {} {
	global comp 
	incr comp(i)
	set t1 $comp(i); set t2 $t1
	while {[GetAscii $comp(i)]!=34} {
		set t2 $comp(i); incr comp(i)
		if {$comp(i)>=$comp(imax)} {error "missing \""}
	}
	incr comp(i)
	append comp(code) "push \"[string range $comp(source) $t1 $t2]\"  ; "
}

proc PushList {} {
	global comp 
	incr comp(i)
	set t1 $comp(i); set t2 $t1
	while {[GetAscii $comp(i)]!=[ascii \}]} {
		set t2 $comp(i); incr comp(i)
		if {$comp(i)>=$comp(imax)} {error "missing \}"}
	}
	incr comp(i)
	append comp(code) "push \{ [string range $comp(source) $t1 $t2] \}  ; "
}

proc DoNothing {} { }

proc SkipLine {} {
	global comp
	while {[GetAscii $comp(i)]!=[ascii \n]} {
		incr comp(i)
		if {$comp(i)>=$comp(imax)} {break}
	}
}

proc CopySource {} {
	global comp
	set comp(code) $comp(source)
}

proc NoCompile {name} {
	error "you can't use proc $name in a colon word"
}

proc CompWord {id} {
	global comp
	append comp(code) "[GetPage $id name] ; "
}

proc appendcode {code} {
	global comp
	append comp(code) $code
}

proc appendcode: {} {
	global comp
	append comp(code) $code
}

proc cc {} {
	GetPage [Unit] compcode
}

proc MakeCompiler {} {
	global comp
	set comp(name) [GetItem] 
	SetPage [Unit] compcode [string range $comp(source) $comp(i) $comp(imax)]
	return -code return
}

proc MakeProc {} {
	global comp
	CopySource
	set name [GetPage [Unit] name]
	SetPage [Unit] compcode " NoCompile $name"
	set comp(message) ""
	return -code return
}

proc MakeCode {} {
	global comp
	set comp(name) [GetItem] 
	set comp(code) "proc $comp(name) \{\} \{ "
	CompileStack
	if {$comp(in)!=""} {append comp(code) "\n$comp(in) "}
	append comp(code) [string range $comp(source) $comp(i) $comp(imax)]
	append comp(code) " \n$comp(out) \} "
	SetPage [Unit] compcode "CompWord [Unit]"
	return -code return
}

proc MakeMacro {} {
	global comp
	set comp(name) [GetItem] 
	append comp(code) "[string range $comp(source) $comp(i) $comp(imax)] "
	SetPage [Unit] page $comp(code)
	SetPage [Unit] compcode "append comp(code) \{[GetPage [Unit] page]\}"
	return -code return
}

proc MakeTcl {} {
	global comp
	incr comp(i)
	append comp(code) [string range $comp(source) $comp(i) $comp(imax)]
	SetPage [Unit] compcode "NoComp"
	return -code return
}

proc MakeColon {} {
	global comp   
	SetPage [Unit] compcode "CompWord [Unit]"
	set comp(code) "proc [GetItem] \{\} \{\n"
	CompileStack
	if {$comp(in)!=""} {append comp(code) "$comp(in) \n"}
	GetItem
	CompileColon	
	append comp(code) " $comp(out) \n\} "
}

proc MakeObjecttype {} {
	global comp
	set objtype [GetItem] 
	SetPage [Unit] compcode "MakeObject ::$objtype"	
	set comp(eval) [string range $comp(source) $comp(i) $comp(imax)]
	uplevel #0 {eval $comp(eval)}
	return -code return
}

proc AppendObjectCode {tclcode obj} {
	global comp
#	puts "tclcode: $tclcode"
	# substitute obj
	set code [string map "obj $obj" $tclcode]
	append comp(code) "$code ; "
#	puts "targetcode: $code"
}

proc AppendMethod {objtype message obj} {
	if {[catch {set tclmethod [set ${objtype}($message)]} ]} {
		error "message '$message' can't be used with $obj"
	}
	AppendObjectCode $tclmethod $obj
	
#	puts ""
#	puts "type: $objtype message: $message name: $obj"
}

proc CompObject {objtype} {
	global comp
	set obj $comp(word)
	set current $comp(i) ;# current source pointer
	GetItem; set id [GetUnit $comp(word)]
	if {$id} {
		set compcode [GetPage $id compcode]
		if {[lindex $compcode 0]=="CompMessage"} {
			set message [lindex $compcode 1]
			if {[array names $objtype -exact $message]!=""} {
				AppendMethod $objtype $message ::$obj
				return
			} 
		}	
	}
	set comp(i) $current  ;# reset source pointer
	set message {}
	AppendMethod $objtype $message ::$obj
}

proc MakeObject {objtype} {
	global comp
	set obj [GetItem] 
	SetPage [Unit] compcode "CompObject $objtype"	
	if {[array names $objtype -exact instance]!=""} {
#		puts "makeobject instancecode"
		AppendObjectCode [set ${objtype}(instance)] $obj
	} {
		AppendObjectCode {set obj {} ; } $obj
	}
	return -code return
}

proc CompMessage {message} {
	global comp locals
	
	error "no object for message '$message'"
	
	set obj [GetItem]
	# local object/variable?
	if [isLocal $comp(word)] {
		set type $locals($obj)
		AppendMethod ::$type $message $comp(word)
	} {
		# global object?
		set id [GetUnit $comp(word)]
		set compcode [GetPage $id compcode]
		if {[lindex $compcode 0]!="CompObject"} {
			error "no object for message '$message'"
		}
		set objtype [lindex $compcode 1]
		AppendMethod $objtype $message ::$obj
	}
}

proc MakeMessage {} {
	global comp
	set comp(name) [GetItem] 
	SetPage [Unit] compcode "CompMessage $comp(name)"
	return -code return
}

proc CompileStack {} {
	global comp locals
	array unset locals   
	set comp(in) {} ; set comp(out) {} ; set stackvar true
	if {[GetItem]!="("} {error "stack error"}  
	GetItem 
	while {$comp(word) != "--"} {
		if {$comp(word)==")"} {error "missing '--'"}
		if {$comp(word)==""} {error "missing '--'"}
		if {$comp(word)=="|"} {set stackvar false; GetItem; continue} 
		if $stackvar {
			set comp(in) [linsert $comp(in) 0 "set $comp(word) \[pop\] ; "]
		} {
			set comp(in) [lappend comp(in) "set $comp(word) 0 ; "] 
		}
		set locals($comp(word)) {variable}
		GetItem
	}
	GetItem 
	while {$comp(word) != ")" } {
		if {$comp(word)==""} {error "missing ')'"}
		set comp(out) [lappend comp(out) "push \$$comp(word) ; "] 
		set locals($comp(word)) {variable}
		GetItem
	}
	set comp(in) [join $comp(in)]
	set comp(out) [join $comp(out)]
}

proc isNumber {word} {	
	return [expr [string is integer -strict $word]||[string is double -strict $word]]
}

proc isLocal {word} {
	global locals
	expr {[array names locals -exact $word]!=""}
}

proc CompileColon {} {
	global comp lcname locals
	while {$comp(word) != "" } {
		if [isLocal $comp(word)] {
			set current $comp(i) ;# current source pointer
			set obj $comp(word); set type $locals($obj)
			GetItem; set id [GetUnit $comp(word)]
			if {$id} {
				set compcode [GetPage $id compcode]
				if {[lindex $compcode 0]=="CompMessage"} {
					AppendMethod ::$type [lindex $compcode 1] $obj	
				} {
					set comp(i) $current  ;# reset source pointer			
 					AppendMethod ::$type "" $obj	
 				}
			} {
				set comp(i) $current  ;# reset source pointer			
 				AppendMethod ::$type "" $obj	
 			}
		} {
			set id [GetUnit $comp(word)]  
			if {$id} {
				eval [GetPage $id compcode]			
			} else {
				if [isNumber $comp(word)] {
					append comp(code) "push $comp(word) ; "
				} {
					error "$comp(word) is undefined" 
				}
			}
		}
		GetItem
	}	
}

proc LoadWord {} {
	global definer comp view locals doi doj dok
	if [Editing] {SaveIt}
	array unset locals
	set doi 0; set doj -1; set dok -2 
	set comp(code) {}
	set comp(objtype) {}
	set comp(message) {}
	GetSource
	if {[GetItem]=="Compiler:"} {MakeCompiler; return}
	CompileColon
	ShowCompCode
	append comp(load) $comp(code)
	if {$comp(code)!=""} {append comp(load) "\n\n"}
}

toplevel .code
text .code.text
pack .code.text

proc ShowCompCode {} {
	global comp
	.code.text delete 1.0 end
	.code.text insert 1.0 $comp(code)
}

.code.text insert 1.0 "Tk $tk_version\n"
.code.text insert end "Tcl $tcl_version"

proc SendTarget {} {
	global comp
	if [TestMode] {
		SendUmbilical  "$comp(load)\n\n"}
}

proc LoadAll {} {
	global comp
	set current [Chapter]
	set c [FirstChapter]
	while {$c != "" && [GetPage $c name] != "--"} {
		SetChapter $c 
		LoadChapter
		set c [Next $c ]
     }
     SetChapter $current
}

proc LoadChapter {} {
	global comp
	set comp(load) ""
	set current [Section]
	set s [FirstSection]
	while {$s != [Chapter]} {
		SetSection $s
		LoadSection
		set s [Next $s]
     }
     SetSection $current
	set dir $::sourcedir
	set name [string tolower [GetPage [Chapter] name]]
	set f [open $dir$name.tcl w]
	puts $f "$comp(load)\n"
	close $f
}

proc LoadSection {} {
	set current [Unit]
	set u [FirstUnit]
	while {$u != [Section]} {
		SetUnit $u
		LoadWord 
		set u [Next $u]
     }
     SetUnit $current
}

proc Load {} {
	global comp
	set comp(load) ""
	switch [GetPage [CurrentPage] type] {
		chapter {LoadChapter}
		section {LoadSection ; SendTarget}
		unit {LoadWord ; SendTarget}
	}

}

proc TestMode {} {
	expr {[lindex [.b.run configure -text] end]=="Test"}
}

proc SetRunButton {} {
	.b.run configure -text Run -command DoRun -bg #eeeeee
#	DisableButton .b.load
}

proc SetTestButton {} {
	.b.run configure -text Test -command DoTest -bg #eeeeee
#	.b.load configure	-bg #eeffff
	EnableButton .b.load
}

proc OpenUmbilical {} {
	puts "Opening umbilical"
	global sock connected
	after 5000 {set connected timeout}
	set sock [socket -async localhost 3456]
	fileevent $sock w {set connected ok}
	vwait connected
	fileevent $sock w {}
	if {$connected=="timeout"} {
		puts "Umbilical timeout"
	} {
		fileevent $sock readable ReadUmbilical
		fconfigure $sock -blocking 0
		puts "Umbilical link ok"
		SetTestButton
	}
}

proc ReadUmbilical {} {
	global sock
	if {[gets $sock line]>=0} {
		if {$line!=""} {
			puts $line
		}
	} {
		close $sock
		puts "Umbilical closed"
		SetRunButton
	}
}

proc SendUmbilical args {
	global sock
	if [catch {puts $sock [join $args]; flush $sock}] {
		close $sock
		puts "Umbilical closed"
		SetRunButton
	}
}

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

proc RunProgram {} {
	if {[catch LoadAll result]} {
		ShowPage [Unit]
		ShowCompCode
		tk_messageBox -type ok -message "Sorry, $result  "
	} {
#	LoadAll
	cd $::sourcedir 
	eval exec [GetBase runcmd] &
	cd .. 
	puts "Starting Target"
	after 3000	OpenUmbilical
}
}

proc DoRun {} {
	if [Editing] {SaveIt}
	RunProgram
}

proc WriteChapter {} { }

proc LoadUnit {} {
	if {[catch Load result]} {
		ShowPage [Unit]
		ShowCompCode
		tk_messageBox -type ok -message "Sorry, $result  "
	}
}

proc EditorButtons {id} {	
	.b.edit configure -text Save -command SaveIt -bg #eeffff
	.b.new configure -text Cancel -command "BrowserButtons; ShowPage $id" \
		-bg #ffeeff
	if {[TestMode]} {.b.load configure	-bg #eeffff}
	DisableButton .b.setup
}

proc AskSetup {} {
	global setup Setup 
	set setup(win) .setup
	if [winfo exists $setup(win)] {return}
	toplevel $setup(win)
	wm title $setup(win) "Setup"
	SetupSearch
	SetupSafe
	SetupFontsize
	SetupSyntax  
#	SetupExtension
	SetupDelimiter
	SetupRun
	SetupOK
	# Position window at button Setup
	wm geometry $setup(win) "250x300+[winfo rootx $Setup]+[winfo rooty $Setup]"
	wm protocol $setup(win) WM_DELETE_WINDOW {EndSetup}
}

proc EndSetup {} {
	global setup view
#	SetBase extension $setup(ext)
	SetBase search $setup(search)
	SetBase comdel $setup(comdel)
	SetBase runcmd $setup(run)
	SetBase syntax $setup(syntax)
	SetBase safe $setup(safe)
	SetBase fontsize $setup(size); AdjustFontsize
	destroy $setup(win)
}

