proc SetCurrent {type} {
	global view
	switch $type {
		chapter {set l $view(chapters)}
		section {set l $view(sections)}
		unit {set l $view(units)}
		default {set l $view(units)}
	}
	set i [$l index active]
	$l selection set $i
	$l itemconfigure $i -bg #000070 -fg white
	focus $l

}

proc SetList {id} {
	global view
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l selection clear [$l index active]
	}	
	if {[Deleted $id]} {return}
	set type [GetPage $id type]
	switch $type {
		chapter {
			SetChapter $id 
		}
		section {
			SetChapter [GetChapter $id];  SetSection $id
		}
		unit {
			set s [GetSection $id]; set c [GetChapter $s]
			SetChapter $c; SetSection $s; SetUnit $id	
		}
	}	
	GetChapters; GetSections; if {![NoSections]} {GetUnits}
	SetCurrent $type
}

proc SetHeight {h} {
	global view 
	if [Editing] return
	set view(height) $h
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l configure -height $h
	}
	# wait a little for the windows 
	set x 0; after 100 {set x 1}; vwait x
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l yview [expr {[$l index active]-$view(height)/2}]
	}	 
}

proc IncrList {} {
	global view
	set h [expr {$view(height)+4}]; if {$h>30} {set h 30}
	SetHeight $h
}

proc DecrList {} {
	global view
	set h [expr {$view(height)-4}]; if {$h<1} {set h 1}
	SetHeight $h
}

proc UnlinkChapter {} {
     global Chapters p n view
     set c [Chapter]
     set n [NextChapter]  
     set i [$view(chapters) index active]
     if {$i>0} {
          set p [lindex $Chapters [incr i -1]] 
          SetPage $p next $n 
     } else {
          SetBase list $n
     }
     # mark the chapter and all items in it as 'deleted'
     SetPage $c next [GetBase delchapters] type deleted
     SetBase delchapters $c
     set s [Section]
     SetSection [FirstSection]
     while {[Section]!=[Chapter]} {
		SetUnitsType deleted
		SetPage [Section] type deleted
		SetSection [NextSection]
	}
	SetSection $s
}

proc DeleteChapter {} {
     global p n
     if [NoChapters] {return}
     UnlinkChapter         
     if [NoChapters] {ClearChapters ; ClearPage ; return}
     if {$n == ""} {SetChapter $p} else {SetChapter $n}
     RefreshChapters
}

proc InsertChapter {c location} {
	global Chapters view
     if {[NoChapters]} {
          SetBase list $c
          SetPage $c next "" type chapter   
     } else {
		if {$location=="before"} {
	    		set i [$view(chapters) index active]
	    		if {$i>0} {
		   		set p [lindex $Chapters [incr i -1]]
		   		SetPage $p next $c
	    		} else { 
		   		SetBase list $c
			}
	    		SetPage $c next [Chapter] type chapter
	 	} else {	      	
			# insert after active chapter
     			set n [NextChapter]
     			SetPage [Chapter] next $c
     			SetPage $c next $n type chapter
     		} 
     }
     SetChapter $c
     set s [Section]
     SetSection [FirstSection]
     while {[Section]!=[Chapter]} {
		SetUnitsType unit
		SetPage [Section] type section
		SetSection [NextSection]
	}
	SetSection $s
     RefreshChapters
	WriteChapter	;# 6cj v51-6
}

proc InsertCDeleted {where} {
     set d [GetBase delchapters]
     if {$d == ""} {return}
     set n [Next $d]
     SetBase delchapters $n
     InsertChapter $d $where
}

proc NewChapter {} {
	if {[Book]} {set name Chapter} else {set name Module}
	set c [AppendPage name $name changes $::version]
     SetPage $c list $c
     InsertChapter $c 1
}

proc AddChapter {} {
	NewChapter; NewSection; NewUnit; FocusChapters
}

proc iActiveSection {} {
	global view
	return [$view(sections) index active]
}

proc iLastSection {} {
	global view
	return [expr {[$view(sections) index end] -1}]
}

proc UnlinkSection {} {
     global Sections p n view
     set s [Section]
     set n [NextSection]
     set i [$view(sections) index active]
     if {$i>0} {
          set p [lindex $Sections [incr i -1]] 
          SetPage $p next $n 
     } else {
          SetPage [Chapter] list $n
     }
     SetPage $s next [GetBase delsections] type deleted
     SetUnitsType deleted
     SetBase delsections $s
}

proc SetUnitsType {t} {
	set u [Unit]
	SetUnit [FirstUnit]
	while {[Unit]!=[Section]} {
		SetPage [Unit] type $t
		SetUnit [NextUnit]
	}
	SetUnit $u
}

proc DeleteSection {} {
     global p n
     if {[NoSections]} {return}
     UnlinkSection         
     if {[NoSections]} {
     		ClearSections; ClearPage 
		if [LinView] {StreamAll}
     		return
     }
     if {$n==[Chapter]} {SetSection $p} else {SetSection $n}
     RefreshSections
	WriteChapter	
}

proc InsertSection {s location} {
     global Sections view
     if {[NoSections]} {
          SetPage [Chapter] list $s
          SetPage $s next [Chapter] type section
     } else {
		if {$location=="before"} {
	    		set i [$view(sections) index active]
	    		if {$i>0} {
		   		set p [lindex $Sections [incr i -1]]
		   		SetPage $p next $s
	    		} else { 
		   		SetPage [Chapter] list $s
			}
	    		SetPage $s next [Section] type section
	 	} else {	      	
			# insert after active section
		     set n [NextSection]
		     SetPage [Section] next $s
		     SetPage $s next $n type section
		}
     }     
     SetSection $s
	SetUnitsType unit
     RefreshSections 
	WriteChapter	;# 6cj v51-6
}

proc InsertSDeleted {l} {
     set d [GetBase delsections]
     if {$d == ""} {return}
     set n [Next $d]
     SetBase delsections $n
     InsertSection $d $l
}

proc NewSection {} {
     set s [AppendPage name "Section" changes $::version]
     SetPage $s list $s
     InsertSection $s 1
}

proc AddSection {} {
	NewSection; NewUnit; FocusSections
}

proc UpSection {} {
	# return if not at first section
	set s [Section]
	if {[iActiveSection]>0} {return 0}
	set c [PrevChapter]
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			set s [LastSection]; break
		}
		set c [PrevChapter]
     }
	GotoSection $s
	return 1
}

proc DownSection {} { 
	# return if not at last section
	set s [Section]
	if {[iActiveSection]<[iLastSection]} {return 0}
	set c [NextChapter]
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			set s [FirstSection]; break
		}
		set c [NextChapter]
     }
	# Here if no more sections in DB
	GotoSection $s
	return 1
}

proc HomeSection {} {
	if {[iActiveSection]==0} {
		UpSection
	} else {
		GotoSection [FirstSection]
	}
}

proc EndSection {} {
	if {[iActiveSection]==[iLastSection]} {
		DownSection
	} else {
		GotoSection [LastSection]
	}
}

proc GotoSection {s} {
	SetList $s
	UpdateSections
}

proc PgUpSections {} {
	global Sections 
	set i [iActiveSection]
	if {$i==0} {
		UpSection
	} else {
		incr i -4; if {$i<0} {set i 0}
		GotoSection [lindex $Sections $i]
	}
}

proc UnlinkUnit {} {
     global Units p n view
     set u [Unit]
     set n [NextUnit]
     set i [$view(units) index active]
     if {$i>0} {
          set p [lindex $Units [incr i -1]] 
          SetPage $p next $n 
     } else {
          SetPage [Section] list $n
     }
     # page marked deleted
     SetPage $u next [GetBase delunits] type deleted
     SetBase delunits $u
}

proc DeleteUnit {} {
     global p n
     if {[NoUnits]} {return}
     UnlinkUnit         
     if {[NoUnits]} {
     		ClearUnits; ClearPage; 
     		if [LinView] {StreamAll}
#     	puts "nounits"
		return
	}
     if {$n == [Section]} {SetUnit $p} else {SetUnit $n}
     RefreshUnits
	WriteChapter	;# 6cj v51-6
}

proc InsertUnit {u location} {
     global Units view
     if {[NoUnits]} {
		SetPage [Section] list $u
		SetPage $u next [Section] type unit
     } else {
		if {$location=="before"} {
	    		set i [$view(units) index active]
	    		if {$i>0} {
		   		set p [lindex $Units [incr i -1]]
		   		SetPage $p next $u
	    		} else { 
		   		SetPage [Section] list $u
			}
	    		SetPage $u next [Unit] type unit
	 	} else {
			# insert after active unit
			set n [NextUnit]
	    		SetPage [Unit] next $u
	    		SetPage $u next $n type unit
	    }	
     }     
     SetUnit $u
     RefreshUnits
	WriteChapter	;# 6cj v51-6
}

proc InsertUDeleted {l} {
     set d [GetBase delunits]
     if {$d == ""} {return}
     set n [Next $d]
     SetBase delunits $n
     InsertUnit $d $l
}

proc NewUnit {} {
     set u [AppendPage name "Unit" changes $::version]
     InsertUnit $u 1
}

proc CopyUnit {} {
	if [Editing] {SaveIt}
	pagevars [Unit] name text source
     set u [AppendPage name "$name" text $text source $source]
     InsertUnit $u 1
}

proc UpUnit {} {
	global view
	# return if not at first unit
	if {[$view(units) index active]>0} {return 0}
	set u [Unit]
	set s [PrevSection] 
	set c [Chapter]
	set sameChapter true
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			if {!$sameChapter} {set s [LastSection]}
			while {$s != $c} {
				SetSection $s
				if {![NoUnits]} {
					GotoUnit [LastUnit]
					return 1
				}
				set s [PrevSection]
			}
		}
		set c [PrevChapter]
		set sameChapter false 
    }
	GotoUnit $u
	return 1
}

proc DownUnit {} {
	global view 
	# return if not at last unit
	if {[$view(units) index active]<[expr {[$view(units) index end]-1}]} {return 0}
	set u [Unit]	
	set s [NextSection]
	set c [Chapter]
	set sameChapter true
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			if {!$sameChapter} {set s [FirstSection]}
			while {$s != $c} {
				SetSection $s
				if {![NoUnits]} {
					GotoUnit [FirstUnit]
					return 1
				}
				set s [NextSection]
			}
		}
		set c [NextChapter]
		set sameChapter false 
     }
	# restore old unit, section and chapter
	GotoUnit $u
	return 1
}

proc iActiveUnit {} {
	return [$::view(units) index active]
}

proc iLastUnit {} {
	return [expr {[$::view(units) index end] -1}]
}

proc PgUpUnits {} {
	global Units 
	set i [iActiveUnit]
	if {$i==0} {
		UpUnit
	} else {
		incr i -4; if {$i<0} {set i 0}
		GotoUnit [lindex $Units $i]
	}
}

proc PgDnUnits {} {
	global Units 
	set i [iActiveUnit]
	set j [iLastUnit]
	if {$i==$j} {
		DownUnit
	} else {
		incr i 4; if {$i>$j} {set i $j}
		GotoUnit [lindex $Units $i]
	}
}

proc HomeUnit {} {
	if {[iActiveUnit]==0} {
		UpUnit
	} else {	
		GotoUnit [FirstUnit]
	}
}

proc EndUnit {} {
	if {[iActiveUnit]==[iLastUnit]} {
		DownUnit
	} else {
		GotoUnit [LastUnit]
	}
}

proc GotoUnit {u} {
	SetList $u
	UpdateUnits	
}

proc LastProgramUnit {} {
	set endUnit [Unit]
	SetChapter [FirstChapter]
	while {[Chapter]!=""} {
		set s [Section]
		SetSection [FirstSection]
		while {[Section]!=[Chapter]} {
			set u [Unit]
			SetUnit [FirstUnit]
			while {[Unit]!=[Section]} {
				set endUnit [Unit]
				SetUnit [NextUnit]
			}
			SetUnit $u
			SetSection [NextSection]
		}
		SetSection $s
		SetChapter [NextChapter]
	}
	GotoUnit $endUnit
}

proc PushForward {id} {
	SetForwardStack [linsert [ForwardStack] 0 $id]
	EnableButton .b.forward
}

proc PopForward {} {
	set page [lindex [ForwardStack] 0]
	SetForwardStack [lreplace [ForwardStack] 0 0]
	if {[llength [ForwardStack]]<2} {DisableButton .b.forward} 
	return $page
}

proc PushPages {page} {
	if {[CurrentPage]!=$page} {
		SetPageStack [linsert [PageStack] end $page]
		EnableButton .b.back
	}
}

proc PopPages {} {
	set page [CurrentPage]
	if {[llength [PageStack]]>1} {SetPageStack [lreplace [PageStack] end end]}
	if {[llength [PageStack]]<2} {DisableButton .b.back}
	return $page
}

proc GoBack {} {
  if {[.b.back cget -state]!="normal"} return
  PushForward [PopPages]
  ShowPage [CurrentPage]		
}

proc GoForward {} {
	if {[.b.forward cget -state]!="normal"} return
	set page [PopForward]
	PushPages $page
	ShowPage [CurrentPage]
}

proc ClearPage {} {
	global view
	$view(title) configure -state normal
	$view(title) delete 1.0 end
	$view(title) configure -state disabled
	$view(text) configure -state normal
	$view(text) delete 1.0 end
	$view(text) configure -state disabled
	$view(code) configure -state normal
	$view(code) delete 1.0 end
	$view(code) configure -state disabled

}

proc ShowTitle {id} {
	global view color
	$view(title) configure -state normal -font title -bg $color(menu) 
	$view(title) delete 1.0 end
	$view(title) insert end [GetPage $id name]  
	$view(title) tag add title 1.0 end   ;# v41-5
	$view(title) configure -state disabled  
}

set oldText ""
set oldCode ""

proc ShowText {id} {
	global color view oldText oldVersion theType 
	if {$oldVersion} {
		set text [GetOldPage $id text]
	} {
		set text [GetPage $id text]; set theType [GetPage $id type]
	}
	$view(text) configure -state normal -font default -bg $color(text)
	$view(text) delete 1.0 end
	set current 1.0   ;# default 
	if {$text!={}} {
		foreach {key value index} $text {
			switch $key {
				text {$view(text) insert $index $value}
				mark {
					if {$value == "current"} { set current $index }
					$view(text) mark set $value $index
					}
				tagon {set tag($value) $index}
				tagoff {$view(text) tag add $value $tag($value) $index}
			}
		}
		$view(text) mark set current $current
	}
	set oldText [$view(text) get 1.0 end] 
	$view(text) configure -state disabled
	if {$oldVersion} {$view(text) configure -state normal}
	LoadImages
}

proc ShowCode {id} {
	global view color oldCode oldVersion 
	$view(code) configure -state normal
	$view(code) delete 1.0 end
	if {$oldVersion} {
		set code [GetOldPage $id source]
	} {
		set code [GetPage $id source] 	 
	}
	$view(code) insert end $code
	set oldCode $code
	$view(code) configure -state disabled -bg $color(code)
	if {$oldVersion} {$view(code) configure -state normal}
}

proc ShowTest {id} {
	global view color oldVersion 
	$view(test) configure -state normal
	$view(test) delete 1.0 end
	if {$oldVersion} {
		set test [GetOldPage $id test]
	} {
		set test [GetPage $id test] 	 
	}
	$view(test) insert end $test
	$view(test) configure -state disabled -bg $color(code)
	if {$oldVersion} {$view(test) configure -state normal}
}

proc ClearVersions {} {
	global view color
	$view(version) configure -state normal -bg $color(menu)
	$view(version) delete 1.0 end
	$view(version) configure -state normal -bg $color(menu)
}

proc ShowPage {id} {
	global view oldVersion
	set oldVersion 0
	PushPages $id   
	TextCodePanes $id
	ShowTitle $id
	if {[Bonus]} {ShowVersions $id; ShowTest $id} {ClearVersions}
	ShowText $id
	ShowCode $id
 	if {[Deleted $id]} {
		$view(version) configure -state normal 
		$view(version) delete 1.0 end
		$view(version) insert end "\[deleted\]" deleted
		$view(version) configure -state disabled 
	}
	SetList $id
	EnableButton .b.recent
	ShowLinPage $id
	ShowTree $id
	ShowFoundText  
}

set edit(pane) ""
set edit(pos) ""

proc UpdateName {} {
	global type view
	switch $type {
		chapter {set l $view(chapters)}
		section {set l $view(sections)}
		unit {set l $view(units)}
		default {set l $view(units)}
	}
	set t [$view(title) get 1.0 "end -1 chars"]
	set i [$l index active]
	$l selection clear 0 end
	$l insert $i " $t"	   ;# insert new, then delete old
	$l delete [expr $i+1] 
	$l selection set $i
	$l itemconfigure $i -bg #000070 -fg white  
	$l activate $i
}

proc CopyName {} {
	global view
	if {![Editing]} {return}
	set i 0; set j 0
	while {![regexp {\s} [GetChar $view(code) $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![regexp {\s} [GetChar $view(code) $j]]} {
		incr j;  if {$j>20} {break}
	}
	set name [$view(code) get "current + $i char" "current + $j char"]
#	puts "name = $name"
	$view(title) delete 1.0 end
	$view(title) insert 1.0 $name
	UpdateName
}

proc Editing {} {
	global view 
	expr {[$view(text) cget -state]=="normal"}
}

proc TextChanged {} {
	global view oldText oldCode newText newCode
	set newText [$view(text) get 1.0 end]
	set newCode [$view(code) get 1.0 end ]
	regsub -all {\s+} $oldText "" oldText
	regsub -all {\s+} $newText "" newText
	regsub -all {\s+} $oldCode "" oldCode
	regsub -all {\s+} $newCode "" newCode
	if {[string equal $oldText $newText] && [string equal $oldCode $newCode]} {
		return 0
	} else {
		return 1
	}
}

proc SaveText {} {
	global ltext view version changelist oldVersion
	set id [CurrentPage]
   	if {[Editing]&&!$oldVersion} {
		BrowserButtons
		if {[Bonus]} {
			if {[TextChanged] && $version!=[lindex $changelist end]} {
				SaveOldPage $id ; UpdateChangelist $id  
		}	}
   		set title [string trim [$view(title) get 1.0 1.end]]
   		# if text exists with no space at end, append space.
   		if {[$view(text) get 1.0 end]!="\n" && [$view(text) get end-2char]!=" "} {
	   		$view(text) insert end " "       ;# preserve tag at end - 079
	   	}
	   	tk::TextSetCursor $view(text) 1.0
	   	eval {$view(text) mark unset} {$view(text) mark names}
	   	$view(text) tag remove foundit 1.0 end
		set text [$view(text) dump 1.0 "end - 1 char"]
		set code [string trim [$view(code) get 1.0 end ]]
		set test " "
		if {[Bonus]} {set test [string trim [$view(test) get 1.0 end]]}
		SavePage $id $text $code local $title [$view(text) index insert] $test
		if [LinView] {StreamAll}
		WriteChapter	         
	}	
}

proc SaveIt {} {
	SaveText
	ShowPage [CurrentPage]  
}

proc EditPage {} {
	global edit type view oldVersion 
	if {$oldVersion} {return}
	set id [CurrentPage] 
	EditorButtons $id
     pagevars $id name page cursor source type 
     foreach pane "$view(title) $view(text) $view(code)" {
		$pane configure -state normal -bg #ffffff
		$pane edit reset
	}
	if {[Bonus]} {$view(test) configure -state normal}
	if {$edit(pane)==""} {
		set pane $view(title)
	} else {
		set pane $edit(pane); set edit(pane) "" ; set cursor $edit(pos)
	}
	if {$cursor==""} {set cursor 1.0}   ;# new item
	$pane mark set insert $cursor
	$pane mark set anchor insert	   
	focus $pane
	ShowFoundText  
}

proc EditIt {} {
	if {![Editing]} {EditPage}
}

proc GetImage {filename} {
	global view
	set p [image create photo]
	$p read $filename
	$view(text) image create end -image $p
}

set URL-Windows [auto_execok start]

proc ShowURL {} {
	global view URL-Windows
	if [Editing] return
	set webadr [eval {$view(text) get} [$view(text) tag prevrange url current]]
 	if {$::tcl_platform(os)=="Darwin"} {
		eval exec open $webadr &
	} {
		eval exec [auto_execok start] $webadr &
	} 
}

proc TextReturn {} {
	global view
	if {[$view(text) index "end-1c"]=="1.0"} {
		focus $view(code); tk::TextSetCursor $view(code) 1.0
	}
	ClearPosx
}

proc LoadImages {} {
	global view
	foreach {a b} [$view(text) tag ranges image] {
		GetImage [$view(text) get $a $b]
	}
}

set posx -1

set posy 0

set dy 0

proc ClearPosx {} {
	global posx
	set posx -1
}

proc Getxy {pane} {
	global posx posy dy
	set b [$pane bbox insert]	
	set posx [lindex $b 0]
	set posy [lindex $b 1]
	set dy [lindex $b 3] 
}

proc -Line {pane} {
	global posx posy dy
	if {$posx < 0} {Getxy $pane}
	incr posy -$dy
	$pane index @$posx,$posy
}

proc +Line {pane} {
	global posx posy dy
	if {$posx < 0} {Getxy $pane}
	incr posy $dy
	$pane index @$posx,$posy
}

proc LineStart {pane} {
	global posy 
	Getxy $pane
	ClearPosx	
	$pane index @0,$posy
}

proc LineEnd {pane} {
	global posy 
	Getxy $pane
	ClearPosx
	$pane index @1000,$posy
}

proc UpLine {pane} {
	global view
	if {[$pane index insert] == "1.0"} {
		switch -glob -- $pane {
			*text {focus $view(title)}
			*code {focus $view(text)}
		}
		ClearPosx
	} {
		tk::TextSetCursor $pane [-Line $pane]
	}
}

proc SelectUpLine {pane} {
	tk::TextKeySelect $pane [-Line $pane]	
}

proc DownLine {pane} {
	global view
	if {[$pane compare insert == "end -1 chars"]} {
		switch -glob -- $pane {
			*title {focus $view(text); tk::TextSetCursor $view(text) 1.0}
			*text {focus $view(code); tk::TextSetCursor $view(code) 1.0}
		}
		ClearPosx
	} {
		tk::TextSetCursor $pane [+Line $pane]
	}
}

proc SelectDownLine {pane} {
	tk::TextKeySelect $pane [+Line $pane]
}

proc StartOfLine {pane} {
	tk::TextSetCursor $pane [LineStart $pane]
}	

proc SelectStartOfLine {pane} {
	tk::TextKeySelect $pane [LineStart $pane]
}

proc EndOfLine {pane} {
	tk::TextSetCursor $pane [LineEnd $pane]
}	

proc SelectEndOfLine {pane} {
	tk::TextKeySelect $pane [LineEnd $pane]
}

proc CurLeft {pane} {
	global view
	if {[$pane tag ranges sel]!=""} {
		tk::TextSetCursor $pane sel.first+1chars    
	}
}

proc CurRight {pane} {
	global view
	if {[$pane tag ranges sel]!=""} {
		tk::TextSetCursor $pane sel.last-1chars  ;# :: tag.last - 1 chars
	}
	if {[$pane compare insert == "end -1 chars"]} {
		switch -glob -- $pane {
			*title {focus $view(text); tk::TextSetCursor $view(text) 1.0}
			*text { focus $view(code); tk::TextSetCursor $view(code) 1.0}
		}
		ClearPosx
	} 
}

proc Click {pane} {
	global view
	if {[Editing]} {
		if {[$pane tag ranges sel]==""} {ClearPosx; return}
		if {[$pane compare [$pane index sel.last] >= [$pane index current]]\
			&& [$pane compare [$pane index sel.first] <= [$pane index current]]} {
			# Mousepointer in range, drag & drop
			set view(dragging) 1
			return -code break  ;# break, else selection is cleared
		} {
			ClearPosx 
		}
	} {
		set view(dragging) 0
		GotoWord $pane
	}
}

proc DoubleClick {pane} {
	global edit 
	if {![Editing]} {
		set edit(pane) $pane
		set edit(pos) [$pane index current]
		EditIt
		return -code break
	}
}

proc DropSelection {pane} {
	global view
	set view(dragging) 0
	set selection [$pane get [$pane index sel.first] [$pane index sel.last]]
	if {[$pane compare [$pane index sel.first] <= [$pane index current]] &&\
		[$pane compare [$pane index sel.last] >= [$pane index current]]} {
		# if mouse is inside, clear selection
		$pane tag remove sel 1.0 end
	} {	
		$pane insert current $selection
		$pane delete [$pane index sel.first] [$pane index sel.last]
	}
}

set searchText ""
set replaceText ""

proc ResetText {pane} {
	variable findText
	if {![Editing]} return
	set range [$pane tag prevrange replaced current+1c]    ;# 056
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$pane delete $a $b
	$pane insert $a $findText
	$pane tag add foundit $a "$a + [string length $findText] chars" 
}

proc FindTracker {v op} {
    	variable findText 
    	variable searchText
	if {$findText == ""} {return}
	# keep iterating while the "findText" search request changes
    	while {1} {
    		if {[string length $findText]<2} {
    			set searchText ""; ClearInfo; break}
    		if {[string compare $findText "  "]<0} break
 		if {$searchText == $findText} break
		set searchText $findText
		ShowFoundText
		set rows [SearchList] ;# this takes time
		after cancel FindTracker		
		update idletasks   ;# process all events now
		# repeat if searchstring has changed while creating list
		if {$findText != $searchText} continue  
		# search is processed, show results
		SearchResults $rows
		after cancel FindTracker
		update idletasks
		if {$findText == $searchText} break
      }      
	ShowFoundText  
}

proc ReplaceText  {pane} {
	global view replaceText
	if {![Editing]} return
	set range [$pane tag prevrange foundit current+1c]    ;# 056
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$pane delete $a $b
	$pane insert $a $replaceText
	if {$pane==$view(title)} {
		$pane tag configure replaced -foreground "sea green"
	} {
		$pane tag configure replaced -foreground "sea green" -background #eeeeee
	}
	$pane tag bind replaced <Button-1> {ResetText %W}
	$pane tag bind replaced <Alt-Button-1> {CopyName; break} 

	$pane tag add replaced $a "$a + [string length $replaceText] chars" 
}

proc ShowFoundText {} {
	global view searchText
	foreach pane "$view(title) $view(text) $view(code)" {
		$pane tag remove foundit 1.0 end
		$pane tag remove replaced 1.0 end
		if {$searchText==""} {continue}
		if {$pane==$view(title)} {
			$pane tag configure foundit -foreground brown
		} {
			$pane tag configure foundit -foreground brown -background #eeeeee
		}
		$pane tag bind foundit <Button-1> {ReplaceText %W}
		$pane tag bind foundit <Alt-Button-1> {CopyName; break} 
		set start [$pane search -count cnt -nocase -- $searchText 1.0 end]
		if {$start!=""} {$pane tag add foundit $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$pane search -count cnt -nocase -- \
				$searchText "$start +1 chars" end]
			if {$start!=""} {$pane tag add foundit $start "$start +$cnt chars"}
		}
	}
}

proc ClearFind {} {
	global replaceText searchText findText
	set findText ""
	set replaceText ""
	set searchText ""
	ShowFoundText
	ClearInfo
}

proc StartFind  {} {
	ClearFind
	focus .s.find
}

proc RecentChanges {} {
    	ClearFind
    	set count 0
    	set lastDay 0
    	set threshold [expr {[clock seconds] - 7 * 86400}]
    	array set pageDays {}
	InsertInfo "Recent Changes:" bold 0
    	foreach i [mk::select wdb.archive -rsort date] {
      		lassign [mk::get wdb.archive!$i id date name who] id date name who
        		# only report last change to a page on each day
      		set day [expr {$date/86400}]
      		if {[info exists pageDays($id)] && $day == $pageDays($id)} continue
      		set pageDays($id) $day
        		#insert a header for each new date
      		incr count
      		if {$day != $lastDay} {
          			# only cut off on day changes and if over 7 days reported
        			if {$count > 10 && $date < $threshold} {break}
        			set lastDay $day
			InsertInfo "\n [clock format $date -gmt 1 \
                		-format {%B %e, %Y}]"		bold		0		 	
      		}
		InsertInfo $name normal $id 
    	}
}

proc SearchList {} {
	global setup
	variable searchText
	variable fields
	if {$searchText == ""} {return ""}
	set fields name
	if {$setup(search)=="textandcode"} {lappend fields text}
	lappend fields source 
	lappend fields changes  
	# escape [ and ] search chars: replace by \[ and \]
	regsub -all {[][?*\\]} $searchText \\\\& searchEscaped
	return [mk::select wdb.pages -rsort date -globnc $fields *${searchEscaped}*] 
}

proc Deleted {id} {
	if {[GetPage $id type]=="deleted"} {return 1} {return 0}
}

proc SearchResults {rows} {
	global searchText
	ClearInfo
	InsertInfo "Found: $searchText" bold [CurrentPage]
	set count 0
	foreach i $rows {
		pagevars $i date name type
		if {[Deleted $i]} {continue}
		InsertInfo $name normal $i
   		incr count
   		set lcname [string tolower $name]
   		set stext [string tolower $searchText]
   		if {$lcname==$stext&&[focus]==".s.find"} {
   			set id [GetUnit $lcname]
   			if $id {
				if {[Editing]} {SaveText}
				ShowPage $id
				focus .s.find
			}
		}
  	}
    	if {$count == 0} {
		InsertInfo "(none)" normal 0
	}
}

proc GetWord {pane} {
	set i 0; set j 0
	while {![Delimiter [GetChar $pane $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![Delimiter [GetChar $pane $j]]} {
		incr j;  if {$j>20} {break}
	}
	return [$pane get "current + $i char" "current + $j char"]
}

proc SearchWord {pane} {
	global findText
	set selection [$pane tag ranges sel]
	if {$selection!=""} {
		set findText [eval {$pane get} $selection ]
	} {
		set findText [GetWord $pane]
	}
}

proc GotoWord {pane} {
	global markedWord
	if {$markedWord!=""} {
		set id [GetUnit $markedWord]
		if {[Editing]} {SaveText}
		ShowPage $id
	}
}

proc CreateBookScript {} {
	global Chapters VersionButton
	set d ./source/
	if {[Book]} {set f [open ${d}book.tcl w]} else {set f [open ${d}project.imp w]}
	set version [GetBase version]
	puts $f "SetVersion $version"
	if {[Bonus]} {puts $f "$VersionButton configure -text $version"}
	if {[GetBase view]=="tree"} {puts $f "SetTreeView"} {puts $f "SetListView"}
	foreach c $Chapters {puts $f [list ImportChapter $d[GetPage $c name].hml]}
	puts $f "SetPageStack 3"
	close $f
}

proc ExportChapters {} {
	global Chapters 
	CreateBookScript
	set current [Chapter]
	foreach c $Chapters {
		SetChapter $c
		FocusChapters; update idletasks
		ExportChapter
	}
	SetChapter $current	
}

proc ImportChapters {} {
	if {[Book]} {source ./source/book.tcl} else {source ./source/project.imp}
}

proc Plus&Minus {} {
	global view
	bind Listbox <plus> {IncrList}
	bind Listbox <minus> {DecrList}
	bind $view(text) <plus> {IncrList}
	bind $view(text) <minus> {DecrList}
}

proc ListboxSelection {} {	
	bind . <<ListboxSelect>> {
	     switch -glob -- %W {
	          *chapters {UpdateChapters}
	          *sections {UpdateSections}
	          *units    {UpdateUnits}
	     }
	}
	# No list item activation at release 
	# (tk script also contains "%w activate @%x,%y")
	bind Listbox <ButtonRelease-1> {tk::CancelRepeat}
}

proc ListNavigation {} {
	global view
	bind $view(chapters) <Left> {FocusUnits} 
	bind $view(chapters) <Right> {FocusSections} 
	bind $view(chapters) <Alt-Left> {GoBack; break}   
	bind $view(chapters) <Alt-Right> {GoForward; break}
	bind $view(sections) <Left> {FocusChapters} 
	bind $view(sections) <Right> {FocusUnits}
	bind $view(chapters) <Control-End> {LastProgramUnit}
	bind $view(sections) <Up> {if [UpSection] break} 
	bind $view(sections) <Down> {if [DownSection] break}
	bind $view(sections) <Home> {HomeSection; break}		
	bind $view(sections) <End> {EndSection; break}		
	bind $view(sections) <Control-End> {LastProgramUnit}
	bind $view(sections) <Prior> {PgUpSections; break}		;# PgUp  v50-6
	bind $view(sections) <Alt-Left> {GoBack; break}   
	bind $view(sections) <Alt-Right> {GoForward; break}
	bind $view(units) <Left> {FocusSections} 
	bind $view(units) <Right> {FocusChapters}
	bind $view(units) <Up> {if [UpUnit] break} 
	bind $view(units) <Down> {if [DownUnit] break} 
	bind $view(units) <Home> {HomeUnit; break}		
	bind $view(units) <End> {EndUnit; break}		
	bind $view(units) <Control-End> {LastProgramUnit}
	bind $view(units) <Prior> {PgUpUnits; break}		;# PgUp
	bind $view(units) <Next> {PgDnUnits; break}		 ;# PgDn
	bind $view(units) <Alt-Left> {GoBack; break}   
	bind $view(units) <Alt-Right> {GoForward; break}
#	bind Listbox <Enter> {focus %W} ;# verwirrt wenn Editing
}

proc ?SafeDel {} {
	global replaceText
	if [GetBase safe] {
		set replaceText "? Shift+Delete"; 
		after 1000 {set replaceText ""}
		return -code break
	}
}

proc Insert&Delete {} {
	global view
	bind $view(chapters) <Shift-Delete> {DeleteChapter}
	bind $view(chapters) <Delete> {?SafeDel; DeleteChapter}
	bind $view(chapters) <Insert> {InsertCDeleted before} 
	bind $view(chapters) <BackSpace> {InsertCDeleted before} 
	bind $view(chapters) <Shift-Insert> {InsertCDeleted after} 
	bind $view(chapters) <Shift-BackSpace> {InsertCDeleted after} 

	bind $view(sections) <Shift-Delete> {DeleteSection}
	bind $view(sections) <Delete> {?SafeDel; DeleteSection}
	bind $view(sections) <Insert> {InsertSDeleted before} 
	bind $view(sections) <BackSpace> {InsertSDeleted before} 
	bind $view(sections) <Shift-Insert> {InsertSDeleted after} 
	bind $view(sections) <Shift-BackSpace> {InsertSDeleted after} 
	
	bind $view(units) <Shift-Delete> {DeleteUnit}
	bind $view(units) <Delete> {?SafeDel; DeleteUnit}
	bind $view(units) <Insert> {InsertUDeleted before} 
	bind $view(units) <BackSpace> {InsertUDeleted before} 
	bind $view(units) <Shift-Insert> {InsertUDeleted after} 
	bind $view(units) <Shift-BackSpace> {InsertUDeleted after} 

}

proc EditItem {} {
	global view 
	bind $view(chapters) <Double-Button-1> {EditIt}
	bind $view(sections) <Double-Button-1> {EditIt}
	bind $view(units) <Double-Button-1> {EditIt}
	bind $view(chapters) <Return> {EditIt}
	bind $view(sections) <Return> {EditPage}
	bind $view(units) <Return> {EditPage}
}

proc StartSearch {} {
	global view
	bind $view(text) <Key-space> {if {![Editing]} {StartFind}}
	bind $view(code) <Key-space> {if {![Editing]} {StartFind}}
	bind Listbox <Key-space> {if {![Editing]} {StartFind}}
}

proc ButtonNew {} {
	switch -glob -- [focus] {
		*chapters {AddChapter}
		*sections {AddSection}
		*units {NewUnit}
	}
}

proc NewPage {} {
	global view
	bind $view(chapters) <Control-n> {AddChapter}
	bind $view(sections) <Control-n> {AddSection}
	bind $view(units) <Control-n> {NewUnit} 
}

proc BindHolon {} {
	ListboxSelection
	ListNavigation
	Plus&Minus
	Insert&Delete
	EditItem	
	StartSearch
	NewPage
}

set setup(search) textandcode

proc SetupSearch {} {
	global setup
	set fsearch [frame $setup(win).search -borderwidth 5]
	pack $fsearch -side top -fill x
	set setup(search) [GetBase search]
	radiobutton $fsearch.b1 -variable setup(search) -text "Search source and comment"\
		-value "textandcode"
	radiobutton $fsearch.b2 -variable setup(search) -text "Search source only"\
		-value "code"
	pack $fsearch.b1 -side top -anchor w
	pack $fsearch.b2 -side top -anchor w
}

proc SetupSyntax {} {
	global setup
	set fsyn [frame $setup(win).syntax -borderwidth 5]
	pack $fsyn -side top -fill x
	set setup(syntax) [GetBase syntax]
	label $fsyn.l -text "Syntax: "
	radiobutton $fsyn.b1 -variable setup(syntax) -text "Tcl" -value "Tcl"
	radiobutton $fsyn.b2 -variable setup(syntax) -text "Forth"	-value "Forth"
	pack $fsyn.l $fsyn.b1 $fsyn.b2 -side left 
}

proc SetupExtension {} {
	global setup
	set fext [frame $setup(win).fext -borderwidth 5]
	pack $fext -side top -fill x
	set setup(ext) [GetBase extension]
	label $fext.l -text "Extension of sourcefiles: " 
	entry $fext.e -textvariable setup(ext) -width 4 -font fixed
	pack $fext.l $fext.e -side left -anchor e
}

proc SetupFontsize {} {
	global setup
	set fsize [frame $setup(win).fsize -borderwidth 5]
	pack $fsize -side top -fill x
	set setup(size) [GetBase fontsize]
	label $fsize.l -text "Font size: " 
	entry $fsize.e -textvariable setup(size) -width 2 -font fixed
	pack $fsize.l $fsize.e -side left -anchor e
}

proc SetupDelimiter {} {
	global setup
	set fdel [frame $setup(win).fdel -borderwidth 5]
	pack $fdel -side top -fill x
	set setup(comdel) [GetBase comdel]
	label $fdel.l -text "Comment delimiter:         " 
	entry $fdel.e -textvariable setup(comdel) -width 4 -font fixed
	pack $fdel.l $fdel.e -side left -anchor e
}

proc SetupRun {} {
	global setup
	set frun [frame $setup(win).frun -borderwidth 5]
	pack $frun -side top -fill x
	set setup(run) [GetBase runcmd]
	label $frun.l -text "Run command: " 
	entry $frun.e -textvariable setup(run) -width 20 -font fixed
	pack $frun.l $frun.e -side left -anchor e
}

proc SetupSafe {} {
	global setup
	set fsafe [frame $setup(win).fsafe -borderwidth 5]
	pack $fsafe -side top -fill x
	set setup(safe) [GetBase safe]
	checkbutton $fsafe.b -text "Safe delete (Shift+Delete)" -variable setup(safe)
	pack $fsafe.b -side left -anchor e
}

proc SetupOK {} {
	global setup
	set fok [frame $setup(win).fok -borderwidth 2]
	pack $fok -side top -fill x
	button $fok.ok -text OK -command {EndSetup}
	pack $fok.ok -fill x
	bind $setup(win) <Return> {EndSetup}
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
	SetupExtension
	SetupDelimiter
	SetupRun
	SetupOK
	# Position window at button Setup
	wm geometry $setup(win) "250x300+[winfo rootx $Setup]+[winfo rooty $Setup]"
	wm protocol $setup(win) WM_DELETE_WINDOW {EndSetup}
}

proc EndSetup {} {
	global setup view
	SetBase extension $setup(ext)
	SetBase search $setup(search)
	SetBase comdel $setup(comdel)
	SetBase runcmd $setup(run)
	SetBase syntax $setup(syntax)
	SetBase safe $setup(safe)
	SetBase fontsize $setup(size); AdjustFontsize
	destroy $setup(win)
}

proc About {} {
	global Setup
	set aboutwin .about
	if [winfo exists .about] {return}
	toplevel .about
	wm title .about "About Holon"
	# Position window at button Setup
	wm geometry .about "300x200+[winfo rootx $Setup]+[winfo rooty $Setup]"
	set at [text .about.t ]
	pack $at -side top -fill x
	$at insert 1.0 "
  Holon Version $::sourceversion\n  
  Copyright (c) 2008 Wolf Wejgaard\n
  This system is provided under the MIT license.
  see http://holonforth.com/new/license.html\n\n
  "
	
	
}

