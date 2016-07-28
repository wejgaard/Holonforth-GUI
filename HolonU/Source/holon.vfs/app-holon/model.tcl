proc SetDBLayout {} {
	mk::view layout wdb.base \
		{list active delchapters delsections delunits mode monitor view \
		 version changes geometry extension search textcolor codecolor bonus \
		 pages forward comdel runcmd syntax safe fontsize running}
	mk::view layout wdb.pages \
		{name page date:I who type next list active cursor source text \
		 changes old compcode test}
	mk::view layout wdb.archive {name date:I who id:I}
	mk::view layout wdb.oldpages {link text source type test}
}

proc CreateStructure {} {
		mk::row append wdb.base mode program  monitor 0  view list		version 001\
			geometry "800x700+50+50" extension tcl search textandcode \
			textcolor #ffffff codecolor #ffffff pages 2 comdel # running 0\
			runcmd "../tclkit ./main.tcl" syntax Tcl safe 1 fontsize 10 bonus 0
		set c [AppendPage type chapter name "Chapter"]
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

proc UpdateRunning {} {
	SetBase running [clock seconds]
 	mk::file commit wdb
	after 5000 UpdateRunning
}

proc OpenDB {} {
	global wdb argc argv appname db
	if {$argc} {
	  	set db [lindex $argv 0]
	} else {
		set db [tk appname].hdb
	}
	set db "./source/$db"  
	set appname [file rootname [file tail $db]]  
	# open or create DB  
	set newdb [expr ![file exists $db]]
	mk::file open wdb $db -shared                 ;# wdb is handle of the db-file
	SetDBLayout
	if {$newdb} {CreateStructure}
	if {[GetBase running]!="" && ([clock seconds]-[GetBase running])<10} {
		wm iconify .  ;# reduce window to icon, only message box is visible
		tk_messageBox -type ok -message "$appname is already running"
		exit
	}	
	UpdateRunning
}

proc CloseDB {} {
	global wdb 	
	SetBase running 0
	mk::file commit wdb
	mk::file close wdb
}

proc Book {} {
	expr {[GetBase mode]=="book"}
}

proc Bonus {} {
	expr {[GetBase bonus]!=0}
}

proc GetBase {field} {
	mk::get wdb.base!0 $field
}

proc SetBase {args} {
	eval mk::set wdb.base!0 $args
}

proc AppendPage {args} {
	set r [eval mk::row append wdb.pages $args]
	return [mk::cursor position r]
}

proc GetPage {i field} {
	mk::get wdb.pages!$i $field
}

proc SetPage {i args} {
	eval mk::set wdb.pages!$i $args
}

proc GetOldPage {i field} {
	mk::get wdb.oldpages!$i $field
}

proc Next {id} {
	GetPage $id next
}

proc PageStack {} {
	GetBase pages
}

proc ForwardStack {} {
	GetBase forward
}

proc SetPageStack {list} {
	SetBase pages $list
}

proc SetForwardStack {list} {
	SetBase forward $list
}

proc Chapter {} {
     GetBase active
}

proc SetChapter {c} {
     SetBase active $c
}

proc FirstChapter {} {
	GetBase list
}

proc NextChapter {} {
	Next [Chapter]
}

proc PrevChapter {} {
	set c [FirstChapter]
	if {$c==[Chapter]} {return ""}
	while {[Next $c]!=[Chapter]} {
		set c [Next $c]
	}
	return $c
}

proc NoChapters {} {
     expr {[GetBase list]==""}
}

proc GetChapter {r} {
	while {[GetPage $r type] == "section"} {
		set r [Next $r]
	}
	return $r
}

proc Section {} {
	GetPage [Chapter] active
}

proc SetSection {s} {
     SetPage [Chapter] active $s
}

proc FirstSection {} {
	GetPage [Chapter] list
}

proc NextSection {} {
	Next [Section]
}

proc PrevSection {} {
	set s [FirstSection]
	if {$s==[Section]} {return [Chapter]}
	while {[Next $s]!=[Section]} {
		set s [Next $s]
	}
	return $s
}

proc LastSection {} {
	set s [FirstSection]
	while {[Next $s]!=[Chapter]} {
		set s [Next $s]
	}
	return $s
}

proc NoSections {} {
     expr {[GetPage [Chapter] list]==[Chapter]}
}

proc GetSection {r} {
	while {[GetPage $r type] == "unit"} {
		set r [Next $r]
	}
	return $r
}

proc Unit {} {
     GetPage [Section] active
}

proc FirstUnit {} {
	GetPage [Section] list
}

proc NextUnit {} {
	Next [Unit]
}

proc LastUnit {} {
	set u [FirstUnit]
	while {[Next $u]!=[Section]} {
		set u [Next $u]
	}	
	return $u
}

proc SetUnit {u} {
     SetPage [Section] active $u
}

proc NoUnits {} {
     expr {[GetPage [Section] list]==[Section]}
}

set version 0     ;# Current version on which we work, same as the change number.

set oldVersion 0

proc SetVersion {v} {
	global version
	set version $v
	SetBase version $v
}

proc pagevars {id args} {
	if {[llength $args] == 1} {
		uplevel 1 [list set $args [mk::get wdb.pages!$id $args]]
	} else {
		foreach x $args y [eval mk::get wdb.pages!$id $args] {
			uplevel 1 [list set $x $y]
		}
 	}
}

proc AddLogEntry {id} {
  	pagevars $id date page who name
  	mk::row append wdb.archive id $id name $name date $date who $who
}

proc SavePage {id text code who newName cursor test {newdate ""}} {
  	set changed 0
  	pagevars $id name page source type 
   	if {$newName != $name} {
   		SetPage $id name $newName
  	}
  	if {$newdate != ""} {
		SetPage $id date $newdate
	}
  	if {$newdate == ""} {
    		SetPage $id date [clock seconds]
    		AddLogEntry $id
  	}
 	SetPage $id source $code who $who cursor $cursor text $text test $test
 	mk::file commit wdb
}

proc CurrentPage {} {
	lindex [PageStack] end
}

proc GetUnit {name} {
	regsub -all {[][?*\\]} $name \\\\& wordEscaped   
	set ids [mk::select wdb.pages -globnc name $wordEscaped type unit]
	set id [lindex $ids end]
	if {$id==""} {set id 0}
	return $id
}

