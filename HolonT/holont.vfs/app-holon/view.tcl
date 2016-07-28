set view(work)  .wframe          ;# Container for the selectable views
set view(page)  .wframe.tframe   ;# Container for title, text and code 
set view(tree)  .wframe.tree 
set view(lists) .wframe.lists

set view(chapters) ""
set view(sections) ""
set view(units) ""
set view(upperpane) ""
set view(titleversion) ""
set view(title) ""
set view(version) ""
set view(text) ""
set view(code) ""
set view(info) ""
set view(test) ""
set view(treeactive) ""

set view(sash0) "0 150"    ;# Position of sash Text/Code
set view(sash1) "0 1000"   ;# Position of sash Code/Test
set view(height) 10    ;# Number of elements visible in each list
set view(dragging) 0

proc ChapterList {} {  
	global view color
	frame $view(lists).cf  -bg $color(menu) -relief flat
	pack $view(lists).cf -side left -fill both -expand 1
	set view(chapters) $view(lists).cf.chapters 
	set chapterScroll $view(lists).cf.cscroll
	listbox $view(chapters) -relief sunken -bd 1 -font listFont  -fg $color(listfg) \
		-bg $color(list) -activestyle none -yscrollcommand "$chapterScroll set"    
	scrollbar $chapterScroll -orient vertical -command "$view(chapters) yview"
	pack $view(chapters) -side left -expand 1 -fill both   
	pack $chapterScroll -side left -fill y
}

proc SectionList {} {  
	global view color
	frame $view(lists).sf  -bg $color(menu) -relief flat
	pack $view(lists).sf -side left -fill both  -expand 1
	set view(sections) $view(lists).sf.sections 
	set sectionScroll $view(lists).sf.sscroll
	listbox $view(sections) -relief sunken -bd 1 -font listFont  -fg $color(listfg) \
		-bg $color(list) -activestyle none -yscrollcommand "$sectionScroll set"    
	scrollbar $sectionScroll -orient vertical -command "$view(sections) yview"
	pack $view(sections) -side left -expand 1 -fill both   
	pack $sectionScroll -side left -fill y
}

proc UnitList {} {  
	global view color
	frame $view(lists).uf  -bg $color(menu) -relief flat
	pack $view(lists).uf -side left -fill both  -expand 1
	set view(units) $view(lists).uf.units
	set unitsScroll $view(lists).uf.uscroll
	listbox $view(units) -relief sunken -bd 1 -font listFont -fg $color(listfg) \
		-bg $color(list) -activestyle none -yscrollcommand "$unitsScroll set" 
	scrollbar $unitsScroll -orient vertical -command "$view(units) yview"
	pack $view(units) -side left -expand 1 -fill both  
	pack $unitsScroll -side left -fill y
}

proc CreateLists {} {  
   	global view
	frame $view(lists) -relief flat -bg white -bd 2
	ChapterList
	SectionList
	UnitList
}

proc mark {w i} {
	global marked color 
	$w itemconfigure $i -fg blue -bg #ddddcc ;# 063
	set marked($w) $i
}

proc unmark {w} {
     global marked
     $w itemconfigure $marked($w) -fg black -bg white
}

set Chapters {}

proc iActiveChapter {} {
	global view
	return [$view(chapters) index active]
}

proc iLastChapter {} {
	global view
	return [expr {[$view(chapters) index end] -1}]
}

proc AppendChapter {c} {
     global Chapters view
     lappend Chapters $c
     $view(chapters) insert end " [GetPage $c name]"
     if {[Chapter]==$c} {
		set i [iLastChapter]
		$view(chapters) activate $i
		mark $view(chapters) $i
     }
}

proc GetChapters {} {
     global Chapters view 
     set Chapters {} 
     $view(chapters) delete 0 [$view(chapters) size]
     if {[NoChapters]} {return}
	set c [FirstChapter]
     while {$c != ""} {
          AppendChapter $c
          set c [Next $c]
     }
     $view(chapters) yview [expr {[iActiveChapter]-$view(height)/2}]
}

proc ClearChapters {} {
     global view
     $view(chapters) delete 0 [$view(chapters) size]
     ClearSections
}

proc RefreshChapters {} {
     global view
     GetChapters
     # needed for UpdateChapters
     $view(chapters) selection set [iActiveChapter] 
	if [LinView] {StreamAll}
     UpdateChapters
     focus $view(chapters)
}

proc UpdateChapters {} {
     global Chapters view 
     if {[NoChapters]} {ClearChapters ; return}
     if {[Editing]} {SaveText}
     unmark $view(chapters)     
     set i [$view(chapters) curselection]
     mark $view(chapters) $i 
     SetChapter [lindex $Chapters $i]
     GetSections
     if {![NoSections]} {GetUnits}
     ShowPage [Chapter]
     focus $view(chapters)
     # keep active chapter in center of pane
     $view(chapters) yview [expr {[$view(chapters) index active]-$view(height)/2}]
     $view(chapters) selection set $i
}

proc FocusChapters {} {
	global view
	if [NoChapters] return
	ShowPage [Chapter]
	$view(chapters) selection set [$view(chapters) index active]
	focus $view(chapters)
}

set Sections {}

proc AppendSection {s} {
     global Sections view
     lappend Sections $s
     $view(sections) insert end " [GetPage $s name]"
     if {[Section]==$s} {
          set i [expr [$view(sections) index end]-1]
          $view(sections) activate $i
          mark $view(sections) $i  
          $view(sections) see $i
     }
}

proc ClearSections {} {
     global view
     $view(sections) delete 0 [$view(sections) size]
     ClearUnits
}

proc GetSections {} {
     global Sections view
     set Sections {} 
     ClearSections
     ClearUnits
     if {[NoSections]} {return}
     set s [GetPage [Chapter] list]
     AppendSection $s
     while {[Next $s]!=[Chapter]} {
          set s [Next $s]
          AppendSection $s
     }
     $view(sections) yview [expr {[$view(sections) index active]-$view(height)/2}]
}

proc RefreshSections {} {
     global view
     GetSections
	if [LinView] {StreamAll}
     ShowPage [Section]
     GetUnits
     $view(sections) selection set [$view(sections) index active]
     focus $view(sections)
}

proc UpdateSections {} {
	global Sections view
	if {[Editing]} {SaveText}
	focus $view(sections)  
	if {[NoSections]} {return}
	unmark $view(sections)      
	set i [$view(sections) curselection]
	mark $view(sections) $i 
	SetSection [lindex $Sections $i]
	ShowPage [Section]
	focus $view(sections)     
	GetUnits
	$view(sections) selection set $i
	$view(sections) yview [expr {[$view(sections) index active]-$view(height)/2}]
}

proc FocusSections {} {
	global view
	focus $view(sections)
	if {[NoSections]} {
		$view(chapters) selection clear [$view(chapters) index active]
		ClearPage
		return
	}
	ShowPage [Section]
	focus $view(sections)
	$view(sections) selection set [$view(sections) index active]
}

set Units {}

proc AppendUnit {u} {
     global Units view
     lappend Units $u
     $view(units) insert end " [GetPage $u name]"
     if {[Unit]==$u} {
          set i [expr [$view(units) index end]-1]
          $view(units) activate $i
          mark $view(units) $i  
     }
}

proc ClearUnits {} {
     global view Units
	set Units {} 
     $view(units) delete 0 [$view(units) size]
}

proc GetUnits {} {
     global Units view
	ClearUnits
     if {[NoUnits]} {return}
     set u [FirstUnit]
     while {$u != [Section]} {
          AppendUnit $u
          set u [Next $u]
     }
     $view(units) yview [expr {[$view(units) index active]-$view(height)/2}]
}

proc RefreshUnits {} {
     global view
	GetUnits
	if [LinView] {StreamAll}
     ShowPage [Unit]
     $view(units) selection set [$view(units) index active] 
     focus $view(units)
}

proc UpdateUnits {} {
     global Units view 
     if {[Editing]} {SaveText}
     if {[NoSections]} {return}
     focus $view(units) 
     if {[NoUnits]} {return}
     unmark $view(units)
     update idletasks  
     set i [$view(units) curselection]
     mark $view(units) $i 
     SetUnit [lindex $Units $i]
     $view(units) selection set $i   
	Text&CodePanes; ShowPage [Unit]
     focus $view(units) 
     # show active unit in center of pane
     $view(units) yview [expr {[$view(units) index active]-$view(height)/2}]
}

proc FocusUnits {} {
     global view
     if {[NoSections]} {return}
     focus $view(units)
     if {[NoUnits]} {
          $view(sections) selection clear [$view(sections) index active]
          $view(chapters) selection clear [$view(chapters) index active]
          ClearPage
          return
     }
     $view(units) selection set [$view(units) index active]
    	Text&CodePanes; ShowPage [Unit]
     focus $view(units)
}

proc VersionPane {} {
	global view color
	set view(version) $view(titleversion).version
	text $view(version) -width 100 -height 1 -state disabled  \
		-font small -bg $color(menu) -relief flat -padx 9 -pady 3
	pack $view(version) -side right -fill x -fill y -expand true
	$view(version) tag configure right -justify right
	$view(version) tag configure bold -font smallbold
	$view(version) tag configure deleted -font title -justify right
 	return $view(version)
}

proc TitleTags {} {
	global view
	$view(title) tag configure title -font title 
}

proc TitleBindings {} {
	global view edit color
	bind $view(title) <Double-Button-1> {set edit(pane) $view(title);\
		$view(title) configure -bg white;\
		set edit(pos) [$view(title) index current]; EditIt; break}
	bind $view(title) <Return> {focus $view(text) ; break}
	bind $view(title) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(title) <Escape> {if {[Editing]} {ShowPage [CurrentPage]}}
	bind $view(title) <Down> {focus $view(text)}
	bind $view(title) <Right> {CurRight $view(title)}
	bind $view(title) <KeyRelease> {UpdateName}
	bind $view(title) <$::RightButton> {SearchWord $view(title); break} 
	bind $view(title) <Control-Button-1> {SearchWord $view(title); break} 
}

proc TitlePane {} {
	global view color
	set view(titleversion) [frame $view(page).tv -relief flat -bg $color(menu)]
	pack $view(titleversion) -side top -fill both -expand true
	set view(title) $view(titleversion).title
	text $view(title) -width 33 -height 1 -state disabled -undo true  \
		-font title -bg $color(menu) -relief flat -padx 9 -pady 3
	pack $view(title) -side left -fill both 
	pack [VersionPane] -side right -fill x -fill y -expand true
	TitleTags
	TitleBindings
 	return $view(titleversion)
}

proc TextTags {} {
	global view
	$view(text) tag configure fixed -font fixed 
	$view(text) tag configure body  -font default 
	$view(text) tag configure code  -font fixed  
	$view(text) tag configure ul -font default 
	$view(text) tag configure ol -font default 
	$view(text) tag configure dt -font default 
	$view(text) tag configure dl -font default 
	$view(text) tag configure i -font italic
	$view(text) tag configure b -font bold
	$view(text) tag configure image -background #ccff99
	$view(text) tag configure marking -font underline -foreground blue
	$view(text) tag configure selection -background lightblue  
	$view(text) tag configure url -font default -foreground blue
	$view(text) tag bind url <Button-1> {catch ShowURL}
}

proc TextKeyBindings  {} {
	global view
	bind $view(text) <Return> {if {![Editing]} {EditPage; break} else {TextReturn}}
	bind $view(text) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(text) <Escape> {if {[Editing]} {ShowPage [CurrentPage]}}
	bind $view(text) <Up> {UpLine $view(text); break}
	bind $view(text) <Down> {DownLine $view(text); break}	
	bind $view(text) <Shift-Up> {SelectUpLine $view(text); break}
	bind $view(text) <Shift-Down> {SelectDownLine $view(text); break}	
	bind $view(text) <Control-Up> {focus $view(title); break}
	bind $view(text) <Control-Down> {focus $view(code); break}
	bind $view(text) <Right> {CurRight $view(text)}	
	bind $view(text) <Left> {CurLeft $view(text)}
	bind $view(text) <Shift-Right> {continue}  ;# bypass CurRight	
	bind $view(text) <Shift-Left> {continue}
	bind $view(text) <Home> {StartOfLine $view(text); break}
	bind $view(text) <End> {EndOfLine $view(text); break}		
	bind $view(text) <Shift-Home> {SelectStartOfLine $view(text); break}
	bind $view(text) <Shift-End> {SelectEndOfLine $view(text); break}		
#?	bind $view(text) <Configure> {%W tag configure hr -tabs %w}
}

proc TextButton3 {x y} {
	global tm view
	set range [$view(text) tag prevrange sel current]
	if {$range!="" && [Editing]} {
		tk_popup $tm $x $y
	} {
		SearchWord $view(text)
	}
}

proc TextMouseBindings  {} {
	global edit view
	bind $view(text) <Button-1> {Click $view(text)} 	
	bind $view(text) <B1-Motion> {if $view(dragging) break}
	bind $view(text) <ButtonRelease-1> {ButtonRelease $view(text)}
	bind $view(text) <Control-Button-1> {SearchWord $view(text); break} 
	bind $view(text) <Double-Button-1> {DoubleClick $view(text)}
	bind $view(text) <$::RightButton> {TextButton3 %X %Y}
	bind $view(text) <Control-Button-1> {TextButton3 %X %Y}
	bind $view(text) <Alt-Button-1> {GotoWord $view(text); break} 
	bind $view(text) <Motion> {MarkIt $view(text)}		
	bind $view(text) <Leave> {$view(text) tag remove marking 1.0 end}
}

proc TextPane {} {
	global view color
	set tf [frame $view(panes).t -relief flat -bg $color(menu)]
	set view(text) $tf.text
	set textScroll $tf.scroll
	text $view(text) -width 72 -height 20 -state disabled -wrap word -font default \
		-relief sunken -yscrollcommand "$tf.scroll set" \
		-exportselection 1 -undo true -pady 5 -padx 10  -tabs {1c 2c 3c 4c 5c 6c}
	scrollbar $tf.scroll -orient vertical -command [list $view(text) yview]
	pack $textScroll -side right -fill y
	pack $view(text) -side left -expand 1 -fill both
	TextTags
	TextKeyBindings ; TextMouseBindings
	TextMenu
	return $tf
}

proc TextBold {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add b $a $b
}

proc TextItalic {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add i $a $b
}

proc TextCode {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add code $a $b
}

proc TextNormal {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag remove b $a $b
	$view(text) tag remove i $a $b
}

proc TextURL {} {
	global view
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add url $a $b
}

proc TextImage {} {
	global view
	set range [$view(text) tag prevrange sel current]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add image $a $b
}

proc TextMenu {} {
	global tm view
	set tm [menu $view(text).menu -tearoff 0]
	$tm add command -label "normal" -command TextNormal
	$tm add command -label "bold" -command TextBold
	$tm add command -label "italic" -command TextItalic
	$tm add command -label "source" -command TextCode
	if {[Book]} {$tm add command -label "image" -command TextImage}
	$tm add command -label "url" -command TextURL
}

proc CodeTags {} {
	global view
	$view(code) tag configure marking -foreground blue -font link
	$view(code) tag configure selection -background lightblue
}

proc CodeKeyBindings  {} {
	global view
	bind $view(code) <Return> {if {![Editing]} {EditPage; break} else {CodeReturn}}
	bind $view(code) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(code) <Escape> {if {[Editing]} {ShowPage [CurrentPage]}}
	bind $view(code) <Up> {UpLine $view(code); break}
	bind $view(code) <Down> {DownLine $view(code); break}	
	bind $view(code) <Shift-Up> {SelectUpLine $view(code); break}
	bind $view(code) <Shift-Down> {SelectDownLine $view(code); break}	
	bind $view(code) <Control-Up> {focus $view(text); break}
	bind $view(code) <Left> {CurLeft $view(code)}
	bind $view(code) <Right> {CurRight $view(code)}	
	bind $view(code) <Shift-Right> {continue}  ;# bypass CurRight	
	bind $view(code) <Shift-Left> {continue}
	bind $view(code) <Home> {StartOfLine $view(code); break}
	bind $view(code) <End> {EndOfLine $view(code); break}		
	bind $view(code) <Shift-Home> {SelectStartOfLine $view(code); break}
	bind $view(code) <Shift-End> {SelectEndOfLine $view(code); break}		
}

proc CodeMouseBindings  {} {
	global edit view
	bind $view(code) <Button-1> {Click $view(code)} 	
	bind $view(code) <B1-Motion> {if $view(dragging) break}
	bind $view(code) <ButtonRelease-1> {ButtonRelease $view(code)}
	bind $view(code) <Control-Button-1> {SearchWord $view(code); break} 
	bind $view(code) <Alt-Button-1> {CopyName; break} 
	if {$::tcl_platform(os)=="Darwin"} {
		bind $view(code) <Command-1> {CopyName; break} 
	}
	bind $view(code) <Double-Button-1> {DoubleClick $view(code)}
	bind $view(code) <$::RightButton> {SearchWord $view(code); break}
	bind $view(code) <Control-Button-1> {SearchWord $view(code); break}
	bind $view(code) <Motion> {MarkIt $view(code)}	
	bind $view(code) <Leave> {$view(code) tag remove marking 1.0 end}
}

proc CodePane {} {
	global view color 
	set pf [frame $view(panes).c -bg $color(menu) -relief flat]
	set view(code) $pf.code
	set codeScroll $pf.scroll
	text $view(code) -width 72 \
    		-height 20 -state disabled -wrap word -font fixed \
		-bg $color(code) -relief sunken -bd 1 -exportselection 1 \
		-yscrollcommand "$pf.scroll set" \
		-undo true -pady 10 -padx 10 -tabs {1c 2c 3c 4c 5c 6c}
	scrollbar $pf.scroll -orient vertical -command [list $view(code) yview]
	pack $codeScroll -side right -fill y
	pack $view(code) -side left -expand 1 -fill both
	CodeTags
	CodeKeyBindings ; CodeMouseBindings
	return $pf
}

proc ButtonRelease {pane} {
	global view
	if $view(dragging) {DropSelection $pane}
#	$pane mark set insert current
#	return -code break
}

proc Delimiter {char} {
	switch [GetBase syntax] {
		Tcl {return	[regexp {[\s\[\]\{\}\(\)\"\$\:\;]} $char]}
		Forth {return	[regexp {\s} $char]}
		default {return	[regexp {[\s\[\]\{\}\(\)\"\$\:\;]} $char]}
	}
}

proc GetChar {pane i} {
	$pane get "current + $i char"
}

proc MarkIt {pane} {
	global markedWord
	if {[Editing]} return
	$pane tag remove marking 1.0 end 
	set markedWord ""
	set i 0; set j 0
	while {![Delimiter [GetChar $pane $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![Delimiter [GetChar $pane $j]]} {
		incr j;  if {$j>20} {break}
	}
	set name [$pane get "current + $i char" "current + $j char"]
    	if [GetUnit $name] {
		$pane tag add marking "current + $i char" "current + $j char"
		set markedWord $name
	} 
}

proc CodeReturn {} {
	global view
	set lineno [expr {int([$view(code) index insert])}]
	set line [$view(code) get $lineno.0 $lineno.end]
	regexp {^(\s*)} $line -> prefix
	if {[$view(code) index insert]!=[$view(code) index "insert linestart"]} {
		after 1 [list $view(code) insert insert $prefix]
	}
	ClearPosx
}

proc SetPanes {} {
	global view
	eval $view(panes) sash place 0 $view(sash0)
	if {[Bonus]} {eval $view(panes) sash place 1 $view(sash1)}
}

proc Text&CodePanes {} {
	global view
	if {[Book]}	{
		NoCodePane
	} else {
		SetPanes 
	}
}

proc NoCodePane {} {
	global view
	$view(panes) sash place 0 0 2000
	if {[Bonus]} {$view(panes) sash place 1 0 2000}
}

proc TextCodePanes {id} {
	switch [GetPage $id type] {
		chapter {NoCodePane}
		section {NoCodePane}
		unit {Text&CodePanes}
	}
}

proc BindInfo {} {
	global view
	bind $view(info) <Button-2> {focus $view(info)}
	bind $view(info) <Motion> {MarkInfo}  
	bind $view(info) <Leave> {$view(info) tag remove marking 1.0 end}
}

proc InfoPane {} {
	global color view
	frame .info -bg $color(menu) -relief flat
	set view(info) .info.text
	text $view(info) -width 20 -state disabled -wrap none -bg $color(info) -relief sunken 
	pack $view(info) -side top -fill both -expand 1
	BindInfo
	$view(info) tag configure normal -font infoNormal
	$view(info) tag configure bold -font infoBold
	$view(info) tag configure marking -foreground blue
	$view(info) tag raise marking
	return .info
}

proc ClearInfo {} {
	global view
	$view(info) configure -state normal
	$view(info) delete 1.0 end
	$view(info) configure -state disabled
}

proc InsertInfo {name style id} {
	global view
	$view(info) configure -state normal 
	$view(info) tag bind goto$id <1> "GotoTree $id; break"
	$view(info) insert end " $name\n" "goto$id $style"
	$view(info) configure -state disabled
}

proc MarkInfo {} {
	global view
	$view(info) tag remove marking 1.0 end
	set name [$view(info) get "current linestart" "current lineend"]
	set name [string trim $name]
 	if [GetUnit $name] {
		$view(info) tag add marking "current linestart" "current lineend"
	}
}

proc StreamTitle {u} {
	global ltext
	$ltext insert end [GetPage $u name]\n bold
}

proc StreamText {u} {
	global ltext
	set text [GetPage $u text]
	if {$text=={}} {return}
	foreach {key value index} $text {
		switch $key {
			text {$ltext insert end $value}
			tagon {set tag($value) end}
			tagoff {$ltext tag add $value $tag($value) end}
		}
	}
	$ltext insert end \n	
}

proc StreamCode {u} {
	global ltext
	$ltext insert end [GetPage $u source]\n
}

proc StreamPage {u} {
	global ltext
	# insert the page with a tag of its own
	set i1 [$ltext index current]
	StreamTitle $u
	StreamText $u 
	set i2 [$ltext index current]
	$ltext tag add text $i1 $i2
	StreamCode $u 
	set i3 [$ltext index current]
	$ltext tag add code $i2 $i3
	set ltag "tag$u"
	$ltext tag add $ltag $i1 $i3
	$ltext tag bind $ltag <Double-Button-1>	"ShowPage $u; focus .lin"
	$ltext insert end \n
}

proc StreamSection {} {
	global ltext 
	set i1 [$ltext index current]
	StreamPage [Section]
	set i2 [$ltext index current]
	if [NoUnits] {return}
	set u [FirstUnit]
	while {$u!=[Section]} {
		set i1 [$ltext index current]
		StreamPage $u
		set i2 [$ltext index current]
		set u [Next $u]
	}
}

proc StreamChapter {} {
	global ltext
	$ltext insert end "   \n" chapter  ;# 081
	set i1 [$ltext index current]
	StreamPage [Chapter]
	set i2 [$ltext index current]
	if [NoSections] {return}
	set current [Section]
	SetSection [FirstSection]
	while {[Section] != [Chapter]} {
		StreamSection
		SetSection [NextSection]
	}
	SetSection $current
}

proc StreamAll {} {
	global ltext 
	if [NoChapters] {return}
	$ltext configure -state normal
	$ltext delete 1.0 end
	set current [Chapter]
	SetChapter [FirstChapter]
	while {[Chapter] != ""} {
		StreamChapter
		SetChapter [NextChapter]
	}
	$ltext configure -state disabled
	SetChapter $current
}

proc LinearView {} {
	global ltext color
	toplevel .lin
	wm geometry .lin 700x900+80+20
	wm title .lin "Linear Text View"
	set ltext [text .lin.text -yscrollcommand ".lin.scroll set"\
		-padx 20 -pady 20 -wrap word  -tabs {1c 2c 3c 4c 5c 6c}
]
	scrollbar .lin.scroll -orient vertical -command [list .lin.text yview]
	pack .lin.scroll -side right -fill y
	pack .lin.text -side left -fill both -expand true
	$ltext tag configure text  -font infoNormal
	$ltext tag configure code  -font fixed
	$ltext tag configure frame  -relief solid -borderwidth 1 
	$ltext tag configure bold -font bold
	$ltext tag configure section -background $color(text)
	$ltext tag configure chapter -background $color(menu)
	$ltext tag configure textpage -background $color(text)
	$ltext tag configure codepage -background $color(code)	
	StreamAll
}

proc LinView {} {
	winfo exists .lin
}

proc RemoveFrames {} {
	global ltext
	set l [$ltext tag ranges frame]	
	if {$l!={}} {
		eval $ltext tag remove frame $l
	}
}

proc ShowLinPage {id} {
	global ltext
	if ![LinView] {return}
	RemoveFrames
	set pagerange [$ltext tag ranges "tag$id"]
	set pagestart [lindex $pagerange 0]
	set pageend [lindex $pagerange 1]
	$ltext tag add frame $pagestart $pageend
	# make page fully visible
	$ltext see $pageend
	$ltext see $pagestart
}

proc CreateTree {} {
	global view theType color
	text $view(tree) -pady 5 -padx 10 -wrap none -relief ridge\
 		-background $color(tree) -width 16 -cursor arrow -font treeFont
	$view(tree) tag configure bold -foreground darkblue -font treeBold
	$view(tree) tag configure section ;# -background $color(tree)
	$view(tree) tag configure chapter ;# -background $color(tree)
	$view(tree) tag configure textpage ;# -background $color(tree)
	$view(tree) tag configure marked -background darkblue -foreground white
	bind $view(tree) <ButtonRelease-1> {SetCurrent $theType}   ;# v51-2
	bind $view(tree) <Button-2> {focus $view(tree)}  ;# 064
	TreeMenu
}

proc ExpandTree {} {
	SetBase view treeexp
	if [Editing] SaveIt
	ShowPage [CurrentPage]
}

proc CompressTree {} {
	SetBase view tree
	if [Editing] SaveIt
	ShowPage [CurrentPage]
}

proc TreeMenu {} {
	global view treemenu
	set treemenu [menu $view(tree).menu -tearoff 0]
	$treemenu add command -label "expand" -command ExpandTree
	$treemenu add command -label "compress" -command CompressTree
	bind $view(tree) <$::RightButton> {tk_popup $treemenu %X %Y}
	bind $view(tree) <Control-Button-1> {tk_popup $treemenu %X %Y}
}

proc GotoTree {id} {
	if {[Editing]} {SaveText}
	ShowPage $id
}

proc TreeSections {} {
	global view 
	if [NoSections] {return}
	set current [Section]
	SetSection [FirstSection]
	while {[Section]!=[Chapter]} {
		set s [Section]
		$view(tree) tag bind tag$s <Button-1> "GotoTree	$s"	
		if {[Section]==$view(treeactive)} {
			$view(tree) insert end "   [GetPage [Section] name]\n" "marked tag$s"
			$view(tree) see end
		} else {
			$view(tree) insert end "   [GetPage [Section] name]\n" "section tag$s"
		}
		if {[GetBase view]=="treeexp"} {
			TreeUnits
		} else {
			if {[Section]==$current} {TreeUnits} 
		}
		SetSection [NextSection]
	}
	SetSection $current
}

proc TreeUnits {} {
	global view 
	if [NoUnits] {return}
	set u [FirstUnit]
	while {$u!=[Section]} {
		$view(tree) tag bind tag$u <Button-1> "GotoTree $u"
		if {$u==$view(treeactive)} {
			$view(tree) insert end "       [GetPage $u name]\n" "marked tag$u"
			$view(tree) see end
		} else {
			$view(tree) insert end "       [GetPage $u name]\n" "textpage tag$u"
		}
		set u [Next $u]
	}
}

proc ShowTreeList {} {
	global view 
	$view(tree) configure -state normal
	$view(tree) delete 1.0 end
	set current [Chapter]
	set c [FirstChapter]
	while {$c != ""} {
		$view(tree) tag bind tag$c <Button-1> "GotoTree	$c; break" 	;# v51-2
		if {$c==$view(treeactive)} {
			$view(tree) insert end "[GetPage $c name]\n"	"bold marked tag$c"
		} else {
			if {$c==$current} {
			$view(tree) insert end "[GetPage $c name]\n" "bold chapter tag$c"
			} else {
			$view(tree) insert end "[GetPage $c name]\n" "chapter tag$c"
			}
		}
		set c [Next $c]
	}
	$view(tree) insert end "______________________\n\n"
	SetChapter $current
	$view(tree) insert end "[GetPage $current name]\n" "bold chapter tag$current"
	TreeSections
	$view(tree) configure -state disabled
}

proc ShowTree {id} {
	global view
	if [NoChapters] {return}
	set view(treeactive) $id
	ShowTreeList 
}

option add *Button.font button
option add *Button.relief groove
option add *Button.disabledForeground black

proc CreateButton {name command} {
	global color buttonBar
	set lcname [string tolower $name]
	set ::$name [button $buttonBar.$lcname -text $name -command $command \
		-bg $color(menu) -width 8 -height 1]
}

proc DisableButton {b} {
	global color
	$b configure -state disabled 

}

proc EnableButton {b} {
	global color
	$b configure -state normal -bg $color(menu)
}

proc DoRun {} {
	if [Editing] {SaveIt}
	cd $::sourcedir; 
	eval exec [GetBase runcmd] &
	cd ..   ;# reset to project dir 087
}

proc BrowserButtons {} {
	.b.edit configure -text Edit -command EditPage -bg #eeffff
	.b.load configure -bg #eeeeee
	.b.new configure -text New -command ButtonNew -bg #eeeeee
	EnableButton .b.back
	EnableButton .b.forward  
	EnableButton .b.setup 
}

proc EditorButtons {id} {	
	.b.edit configure -text Save -command SaveIt -bg #eeffff
	.b.new configure -text Cancel -command "BrowserButtons; ShowPage $id" \
		-bg #ffeeff
	DisableButton .b.setup
}

proc ButtonBar {} {
	global color buttonBar menu
	set buttonBar .b
	frame $buttonBar -relief ridge -bd 1 -bg $color(menu)
	CreateButton Back {if [Editing] {SaveIt}; GoBack}   
	CreateButton Forward {if [Editing] {SaveIt}; GoForward}
	CreateButton New ButtonNew
	CreateButton Edit EditPage
	CreateButton Setup AskSetup
	CreateButton Load LoadUnit
	CreateButton Run DoRun
	CreateButton Recent RecentChanges
	CreateButton Clear ClearFind
	if {[Book]} {
		$::Setup configure -text "View"
		pack $::Back $::Forward $::Setup $::New $::Edit \
		$::Recent	$::Clear -side left -padx 0 -pady 0 
	} {
		pack $::Back $::Forward $::Setup $::New $::Edit $::Load $::Run \
		$::Recent	$::Clear -side left -padx 0 -pady 0 
	}
	$::Edit configure -bg #eeffff
	SetupMenu 
}

set menu(chapters) ""
set menu(sections) ""
set menu(units) ""
set menu(tree) ""
set menu(text) ""
set menu(setup) ""
set menu(version) ""
set menu(view) ""

proc ChapterMenu {} {
	global menu view
	set menu(chapters) [menu $view(lists).cmenu -tearoff 0]
	$menu(chapters) add command -label "New Module" -command AddChapter
	if {[Book]} {
	$menu(chapters) add command -label "Export Chapter" -command ExportChapter
	$menu(chapters) add command -label "Import Chapter" -command ImportFile
	$menu(chapters) add command -label "Export Book" -command ExportChapters
	$menu(chapters) add command -label "Import Book" -command ImportChapters
	$menu(chapters) add command -label "Print Chapter" -command PrintChapter
	} {
	$menu(chapters) add command -label "Export Module" -command ExportChapter
	$menu(chapters) add command -label "Import Module" -command ImportFile
	$menu(chapters) add command -label "Export Project" -command ExportChapters
	$menu(chapters) add command -label "Import Project" -command ImportChapters
	$menu(chapters) add command -label "Print Module" -command PrintChapter
	}	
}

proc SectionMenu {} {
	global menu view
	set menu(sections) [menu $view(lists).smenu -tearoff 0]
	$menu(sections) add command -label "New Section" -command AddSection
	if {[Book]} {
		$menu(sections) add command -label "Save as RTF" -command rtfSection
	} else {
		$menu(sections) add command -label "Print Section" -command PrintSection
	}
}

proc UnitMenu {} {
	global menu  view
	set menu(units) [menu $view(lists).umenu -tearoff 0]
	$menu(units) add command -label "New Unit" -command NewUnit
	if {[Book]} {
		$menu(units) add command -label "Save as RTF" -command rtfUnit
	} else {
		$menu(units) add command -label "Copy Unit" -command CopyUnit
		$menu(units) add command -label "Load Unit" -command LoadUnit
		$menu(units) add command -label "Print Page" -command PrintUnit
	}
}

proc ListMenus {} {
	global view menu
	ChapterMenu
	bind $view(chapters) <$::RightButton> {tk_popup $menu(chapters) %X %Y}
	bind $view(chapters) <Control-Button-1> {tk_popup $menu(chapters) %X %Y}
	SectionMenu 
	bind $view(sections) <$::RightButton> {tk_popup $menu(sections) %X %Y}
	bind $view(sections) <Control-Button-1> {tk_popup $menu(sections) %X %Y}
	UnitMenu 
	bind $view(units) <$::RightButton> {tk_popup $menu(units) %X %Y}
	bind $view(units) <Control-Button-1> {tk_popup $menu(units) %X %Y}
}

proc SetupMenu {} {
	global menu 
	set menu(setup) [menu .b.setup.smenu -tearoff 0]
	if {![Book]} {
		$menu(setup) add command -label "System parameters" -command {AskSetup}
	}
	$menu(setup) add command -label "Lists view" -command {SetListView}
	$menu(setup) add command -label "Tree view" -command {SetTreeView}
	$menu(setup) add command -label "Text view" \
		-command {LinearView; update idletasks; ShowLinPage [CurrentPage]}
	$menu(setup) add command -label "About" -command {About}
	$menu(setup) add command -label "Console" -command {catch {console show}}
	bind .b.setup <Button-1> {tk_popup $menu(setup) %X %Y; break}
}

proc StatusFindReplace {} {
	global color findText replaceText 
	label .s.ftext -text " Find " -bg $color(menu) -font button 
	entry .s.find -textvariable findText -font fixed -width 18
	label .s.rtext -text " Replace " -bg $color(menu) -font button
	entry .s.replace -textvariable replaceText -font fixed -width 18
	if {[Bonus]} {
		pack .s.replace .s.rtext .s.find .s.ftext	-side right -expand 0 -fill x 
	} {
		pack .s.ftext .s.find .s.rtext .s.replace	-side left -expand 0 -fill x 
	}
}

proc StatusVersion {} {
	global changeEntry VersionButton color version
	set changeEntry [entry .s.chtext -textvariable changeText -font fixed -width 25\
		-disabledbackground $color(menu) -disabledforeground black]
	set VersionButton [button .s.cm -text "$version"  \
		-bg $color(menu) -font fixed -width 8 -height 1]
	pack $VersionButton -side left -expand 0 
	pack $changeEntry -side left -expand 1 -fill x 
	bind $changeEntry <Return> {LogChangeText}
	bind $changeEntry <Double-Button-1> {OpenChangeText}
	InitChanges
	VersionMenu
}

proc StatusBar  {} {
	global color      
	frame .s -bg $color(menu) -relief ridge -bd 1 -padx 0 -pady 0
	if {[Bonus]} {StatusVersion}
	StatusFindReplace
	return .s
}

proc CreateColors {} {
	global color
	set color(text)    #ffffff
	set color(code)    #ffffff 
	set color(menu)    #eeeeee  
	set color(disable) #eeeeee
	set color(info)    #eeeeee
	set color(list)    $color(text)
	set color(tree)    #eeeeee
	set color(listfg)  #000000
}

proc CreateFonts {} {
	set textfont Helvetica; 	set fixedfont Courier; 	set versionfont Verdana
	set textsize  [GetBase fontsize] 
	set titlesize [expr $textsize+4]
	set infosize  [expr $textsize-1]
	set smallsize [expr $textsize-3]
	font create default -family $textfont -size $textsize 
	font create underline -family $textfont -size $textsize -underline true
	font create bold -family $textfont -size $textsize -weight bold
	font create italic -family $textfont -size $textsize -slant italic
	font create button -family $textfont -size $textsize
	font create title -family $textfont -size $titlesize
	font create fixed -family $fixedfont -size $textsize 
	font create link -family $fixedfont -size $textsize -underline true
	font create infoNormal -family $textfont -size $infosize
	font create infoBold -family $textfont -size $infosize -weight bold
	font create treeFont -family $textfont -size $infosize  
	font create treeBold -family $textfont -size $infosize -weight bold
	font create listFont -family $textfont -size $textsize  
	font create small -family $versionfont -size $smallsize
	font create smallbold -family $versionfont -size $smallsize -weight bold
	font create smallitalic -family $versionfont -size $smallsize -slant italic
}

proc AdjustFontsize {} {
	set textsize  [GetBase fontsize] 
	foreach f "default underline bold italic button fixed link listFont" {
		font configure $f -size $textsize
	}
	foreach f "infoNormal infoBold treeFont treeBold" {
		font configure $f -size [expr $textsize-1]
	}
	foreach f "small smallbold smallitalic" {
		font configure $f -size [expr $textsize-3]
	}
	font configure title -size [expr $textsize+4]
}

proc GetSashPositions {} {
	global view
	set view(sash0) [$view(panes) sash coord 0]
	if {[Bonus]} {set view(sash1) [$view(panes) sash coord 1]}
}

proc CreatePage {} {
	global view 
	frame $view(page) -relief flat
	set view(panes) $view(page).panes
	panedwindow $view(panes) -orient vertical -relief groove -borderwidth 0 \
		-sashrelief flat -opaqueresize 1 -sashwidth 1 
	$view(panes) add [TextPane]
	$view(panes) add [CodePane]
	if {[Bonus]} {$view(panes) add [TestPane]}
	grid [TitlePane] -row 0  -sticky news
	grid $view(panes) -row 1  -sticky news  
	grid rowconfigure $view(page) 0 -weight 0
	grid rowconfigure $view(page) 1 -weight 1 
	grid columnconfigure $view(page) 0 -weight 1  
	bind $view(panes) <ButtonRelease-1> {after 100 GetSashPositions}
}

proc CreateView {} {
	global buttonBar view
	ButtonBar	
	grid [StatusBar] -row 1 -column 0 -columnspan 1 -sticky news  
	grid $buttonBar -row 0 -column 0  -sticky new  
	grid [InfoPane] -row 0 -column 1 -rowspan 3 -sticky news  
	frame $view(work)
	grid $view(work) -row 2 -column 0 -sticky news
	CreateLists 
	CreateTree 
	CreatePage
	if {[GetBase view]=="tree"} {
		pack $view(tree) -side left -fill y
		pack $view(page) -side left -fill both -expand yes
		place $view(lists) -x -2 -y -2
	} else {
		pack $view(lists) -side top -fill x
		pack $view(page) -side top -fill both -expand yes
	}
	grid columnconfigure . 0 -weight 1
	grid rowconfigure . 0 -weight 0
	grid rowconfigure . 1 -weight 0
	grid rowconfigure . 2 -weight 1 
#	update idletasks  
	update  ;# !! suppresses sourcepane in modules also at start of program.
}

proc SetListView {} {
	global view
	place forget $view(lists)
	pack forget $view(tree)
	pack forget $view(page)
	pack $view(lists) -side top -fill x
	pack $view(page) -side top -fill both -expand yes
	SetBase view list
}

proc SetTreeView {} {
	global view
	pack forget $view(lists)
	pack forget $view(page)
	pack $view(tree) -side left -fill y
	pack $view(page) -side left -fill both -expand yes
	place $view(lists) -x -2 -y -2
	SetBase view tree
}

proc ChangeView {} {
	if {[GetBase view]=="list"} {
		SetTreeView
	} else {
		SetListView
	}
}

proc InitHolon {} {
	global topwin 
	set topwin "."
	CreateFonts
	CreateColors
	CreateView
	ListMenus
	BindHolon
}

proc InitSpecial {} {
}

proc ShowHolon {} {
	global view
	GetChapters
	if {[NoSections]} {
		ShowPage [Chapter]
		$view(chapters) selection set [$view(chapters) index active]
		focus $view(chapters)
		return
	}
	GetSections
	if {[NoUnits]} {
		ShowPage [Section]
		$view(sections) selection set [$view(sections) index active]
		focus $view(sections)
		return
	}
	GetUnits
	ShowPage [CurrentPage]
}

proc RunHolon {}  {
	global topwin findText 
	InitHolon
	InitSpecial
  	ShowHolon
	trace variable findText w {after cancel FindTracker; after 500 FindTracker}  
	wm protocol $topwin WM_DELETE_WINDOW {
		SetBase geometry [wm geometry .]      
		destroy $topwin 
	}
	update idletasks
	after idle raise $topwin
	tkwait window $topwin
}

