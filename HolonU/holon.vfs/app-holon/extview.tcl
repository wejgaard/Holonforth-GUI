set pageSize 62

proc PrintHeader {} {
	global pf page line appname version
	set line 0
	if {$page>0} {puts -nonewline $pf \f}
	incr page
	set d [clock format [clock seconds] -format "%x"]
	set hChapter [GetPage [Chapter] name]
	set hSection [GetPage [Section] name] 
	set hAppname [string totitle $appname]
	set l "$hAppname/$hChapter/$hSection"
	set c [string length $l]
	puts -nonewline $pf $l
	while {$c<40} {puts -nonewline $pf " "; incr c}
	puts	$pf "$version / $d              Page $page"
	puts $pf \n
}

proc IncrLine {} {
	global line pageSize
	incr line
	if {$line>$pageSize} {PrintHeader}
}

proc WriteLine {l} {
	global pf 
	regsub -all {\t} $l "    " l
	puts $pf $l 
	IncrLine
}

proc PrintTitle {id} {
	set l [GetPage $id name]
	WriteLine $l
	set n [string length $l]
	set l [string repeat "-" $n]
	WriteLine $l
}

proc RemoveTags {t} {
	set text ""	
	foreach {key value index} $t {
		if {$key=="text"} {
			append text $value
		}
	}
	return $text
}

proc PrintTextLine {l} {
	global pf
	set length 78
	while {[string length $l] > $length} {
		set w [string wordstart $l $length]
		# if w points to first char of word, move to separator.
		set c [string index $l $w]
		if {[string match {[a-zA-Z0-9]} $c]} {incr w -1}
		# if separator is not space or dot, include in word.
		set c [string index $l $w]
		if {![string match {[ .]} $c]} {incr w -1}
		if {![Book]} {puts -nonewline $pf "[GetBase comdel] "}
		WriteLine [string range $l 0 $w]
		set l [string replace $l 0 $w]
	}
	if {![Book]} {puts -nonewline $pf "[GetBase comdel] "}
	WriteLine $l
}

proc PrintText {r} {
	global pf
	set t [RemoveTags [GetPage $r text]]
	set lines [split $t \n]
	set n [llength $lines]
	set i 0
	while {$i<$n} {
		PrintTextLine [lindex $lines $i]
		incr i
	}	
}

proc PrintCode {id} {
	global pf line pageSize
	set t [GetPage $id source]
	set lines [split $t \n]
	set n [llength $lines]
	if {[expr $n+$line]>$pageSize} {PrintHeader}
	set i 0
	while {$i<$n} {
		WriteLine [lindex $lines $i]
		incr i
	}	
	puts $pf ""; IncrLine
}

proc PrintPage {r} {
	global pf 
	PrintText $r
	PrintCode $r
}

proc PrintSectionPages {} {
	global  pf
	PrintHeader
	PrintTitle [Section]
	PrintText [Section]
	WriteLine ""
	if {![NoUnits]} {
	     set u [FirstUnit]
	     PrintPage $u
	     while {[Next $u] != [Section]} {
			set u [Next $u]
			PrintPage $u
	     }
	}
}

proc PrintSectionsList {}  {
	global pf
 	set s [FirstSection]
	while {$s != [Chapter]} {
		PrintTitle $s
		PrintText $s
		puts $pf ""; IncrLine	     
		set s [Next $s]
	 }
}

proc StartPrint {} {
	global pf page 
	set pf [open print.txt w]
	fconfigure $pf -encoding binary 
 	set page 0
}

proc EndPrint {} {
	global pf
	close $pf
	 if {$::tcl_platform(os)=="Darwin"} {
		eval exec open print.txt &
	} {
		if [catch {eval exec wordpad.exe print.txt &}] {
			eval exec [auto_execok start] print.txt &
		}
	}
}

proc PrintUnit {} {
 	StartPrint 
	PrintHeader	
	PrintPage [Unit]
	EndPrint
}

proc PrintSection {} {
	StartPrint 
	PrintSectionPages 
	EndPrint
}

proc PrintChapter {} {
	global pf 
	if {[NoSections]} {return}
	set current [Section]
	SetSection [FirstSection]
 	StartPrint 
	PrintHeader
	PrintTitle [Chapter]
	PrintText [Chapter]
	WriteLine ""
	PrintSectionsList
     while {[Section] != [Chapter]} {
		PrintSectionPages 
		SetSection [NextSection]
	}
	EndPrint
	SetSection $current
}

proc quote {q} {
	regsub -all {ä} $q {\'e4} q
	regsub -all {ö} $q {\'f6} q 
	regsub -all {ü} $q {\'fc} q
	regsub -all {Ä} $q {\'c4} q
	regsub -all {Ö} $q {\'d6} q
	regsub -all {Ü} $q {\'dc} q
	regsub -all {\n} $q {\\par } q
	regsub -all "{" $q {\{ } q
	regsub -all  } $q {\} } q
	return $q
}

proc TextToRTF {r} {
	set result ""
	set text [GetPage $r text]
	foreach {key value index} $text {
		switch -exact -- $key {
			text {append result [quote $value]}
			mark {}
			tagon { 
				switch $value {
					i {append result "\}\{\\i "}
					b {append result "\}\{\\b "}
					default {}
				}
			}
			tagoff {append result "\}\{"}
			default {}
		}
	}
	return $result
}

proc rtfOpen {} {
	global f
	set f [open text.rtf w]
	puts $f "\{\\rtf1\\ansi\{"
}

proc rtfWrite {r} {
	global f
	puts -nonewline $f "\}\{\\b "
	puts $f [quote [GetPage $r name]]
	puts -nonewline $f "\}\{"
	puts $f "\\par "
	puts $f [TextToRTF $r]
	puts $f "\\par "
	puts $f "\\par "
}

proc rtfClose {} {
	global f
	puts $f "\}\}"
	puts $f \f
	close $f
}

proc rtfUnit {} {
	rtfOpen
	rtfWrite [Unit]
	rtfClose
}

proc rtfSectionPages {s} {
	rtfWrite $s
	if {[NoUnits]} {return}
     set u [GetPage $s list]
     while {$u != $s} {
		rtfWrite $u
		set u [Next $u]
     }
}

proc rtfSection {} {
	rtfOpen
	rtfSectionPages [Section]
	rtfClose
}

proc rtfChapter {} {
 	rtfOpen
	rtfWrite [Chapter]
	if {![NoSections]} {
	     set s [GetPage [Chapter] list]
	     while {$s != [Chapter]} {
			rtfSectionPages $s
			set s [Next $s]
	     }
	}
	rtfClose
}

proc OpenWriteFile {} {
	set dir $::sourcedir
	set name [string tolower [GetPage [Chapter] name]]
	set ext [GetBase extension]
	set f [open $dir$name.$ext w]
 	fconfigure $f -encoding binary
	return $f
}

proc WriteSection {f} {
	set comdel [GetBase comdel]
#	puts $f "\n$comdel === [GetPage [Section] name] ===\n"
	if {[NoUnits]} {return}
	set u [FirstUnit]
	while {$u != [Section]} {
		puts $f [GetPage $u source]\n
		set u [Next $u]
	}
}

proc WriteChapter {} {
	global import
	if {$import} {return}                  
	if {[NoSections]} {return}
	if {[Book]} {return}
	set f [OpenWriteFile]
	set current [Section]
	SetSection [FirstSection]  
	while {[Section] != [Chapter]} {
		WriteSection $f 
		SetSection [NextSection]
	}
	SetSection $current
	close $f
}

proc WriteAllChapters {} {
	global import
	set import 0
	if {[NoChapters]} {return}
	set current [Chapter]    
	SetChapter [FirstChapter]
     while {[Chapter]!=""} {
          WriteChapter 
          SetChapter [NextChapter]
     }
	SetChapter $current
}

proc OpenExportFile {} {
	set d $::sourcedir
	set n [GetPage [Chapter] name]
	set f [open $d$n.hml w]
 	fconfigure $f -encoding binary
	return $f
}

proc ExportRecord {r f} {
	puts $f "<Name> [GetPage $r name]"
	set t [GetPage $r text] ; if {$t!=""} {puts $f "<Comment> $t"}
	set s [GetPage $r source] ; if {$s!=""} {puts $f "<Source> $s"}
	set v [lindex [GetPage $r changes] end] ; if {$v!=""} {puts $f "<Version> $v"}
}

proc ExportUnit {f} {
	puts $f "<Unit>"
	ExportRecord [Unit] $f
}

proc ExportSection {f} {
	puts $f "<Section>"
	ExportRecord [Section] $f
	if {[NoUnits]} {
		return
	}
	set current [Unit]
	SetUnit [FirstUnit]
	while {[Unit] != [Section]} {
		ExportUnit $f
		SetUnit [NextUnit]
	}
	SetUnit $current
}

proc ExportChapter {} {
	set f [OpenExportFile]
	if {[Book]} {puts $f "<Chapter>"} else {puts $f "<Module>"}
	ExportRecord [Chapter] $f
	if {[NoSections]} {
		return
	}
	set current [Section]
	SetSection [FirstSection]  
	while {[Section] != [Chapter]} {
		ExportSection $f 
		SetSection [NextSection]
	}
	SetSection $current
	close $f
}

proc PutCode {} {
	global item field code
	if {$code!=""} {
		SetPage $item $field $code
		set code ""
	}
}

proc ImportChapter {file} {
	global item field code import version
	set f [open $file r]
 	fconfigure $f -encoding binary
	set code ""
	set import 1           ;# WriteChapter abschalten 
	while {[gets $f line] >= 0} {
		if {[regexp {^<(.+?)>} $line tag name]} {
			switch $tag {
				<Chapter> {NewChapter ; set item [Chapter]}
				<Module> {NewChapter ; set item [Chapter]}
			 	<Section> {PutCode ; NewSection ; set item [Section]}
			 	<Unit>    {PutCode ; NewUnit ; set item [Unit]}
			 	<Name>    {SetPage $item name [string range $line 7 end]}
			 	<Text>    {set code [string range $line 7 end]; set field text}
			 	<Comment> {set code [string range $line 10 end]; set field text}
				<Source>  {PutCode ; set code [string range $line 9 end]; set field source}
				<Code>    {PutCode ; set code [string range $line 7 end]; set field source}
				<Version> {PutCode ; set code $version; set field changes}
			}
		} { 
			set code $code\n$line	
		}	
	}
	PutCode
	close $f
	UpdateUnits
	set import 0; WriteChapter
	update idletasks
}

proc ImportFile {} {
	set file [tk_getOpenFile -filetypes {{"" {".hml"}}} -initialdir ./source ]
	if {$file==""} {return}
	ImportChapter $file
}

