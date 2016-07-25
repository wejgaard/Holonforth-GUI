push {} ; array set board [pop] ; 

push "white"  ; set white [pop] ; 

push "black"  ; set black [pop] ; 

push $::white ; set toMove [pop] ; 

push {} ; set history [pop] ; 

proc reset {} {
set setup 0 ;  set i 0 ;  set x 0 ;  set y 0 ;  
push { r n b q k b n r
	  p p p p p p p p
	  . . . . . . . .
	  . . . . . . . .
	  . . . . . . . .
	  . . . . . . . .
	  P P P P P P P P
	  R N B Q K B N R 
	 }  ; set setup [pop] ; push 0 ; set i [pop] ; push { 8 7 6 5 4 3 2 1  }  ; push { y  }  ; foreach [pop] [pop] {
push { A B C D E F G H  }  ; push { x  }  ; foreach [pop] [pop] {
push $i ; @list $setup [pop] ; push "$x$y"  ; set ::board([pop]) [pop] ; incr i ; }
}
push $::white ; set ::toMove [pop] ; push {} ; set ::history [pop] ;   
} 

proc moveMan {} {
set move [pop] ;  set to 0 ;  set from 0 ;  set fromMan 0 ;  
push "-"  ; push $move ;  foreach {j} [split [pop] [pop]] {push $j} ; set to [pop] ; set from [pop] ; push $from ; push $::board([pop]) ; set fromMan [pop] ; push $to ; push $::board([pop]) ; set toMan [pop] ; push $toMan ; push "-$toMan"  ; append move [pop] ; push $fromMan ; push $to ; set ::board([pop]) [pop] ; push "."  ; push $from ; set ::board([pop]) [pop] ; push $move ; lappend ::history [pop] ; push $::toMove ; push $::white ; = ; if [pop]  {
push $::black ; } else {
push $::white ; }
set ::toMove [pop] ;  push $toMan ;  
} 

proc color {} {
set c [pop] ;  
push $c ; ascii ; push 97 ; < ; if [pop]  {
push $::white ; } else {
push $::black ; }
set color [pop] ;  push $color ;  
} 

proc sameSide? {} { 
set b [pop] ;  set a [pop] ;  
	set f [regexp {[a-z][a-z]|[A-Z][A-Z]} $a$b] 
push $f ;  } 

push $::white ; set side [pop] ; 

proc valid? {} {
set move [pop] ;  set from 0 ;  set to 0 ;  set fromMan 0 ;  set toMan 0 ;  set x 0 ;  set y 0 ;  set x0 0 ;  set y0 0 ;  set x1 0 ;  set y1 0 ;  set dx 0 ;  set dy 0 ;  set adx 0 ;  set ady 0 ;  
push "-"  ; push $move ;  foreach {j} [split [pop] [pop]] {push $j} ; set to [pop] ; set from [pop] ; push $to ; push {} ; = ; if [pop]  {
push 0 ; return ; }
push $from ; push $::board([pop]) ; set fromMan [pop] ; push $to ; push $::board([pop]) ; set toMan [pop] ; push $fromMan ; color ; push $::toMove ; != ; if [pop]  {
push 0 ; return ; }
push $fromMan ; push $toMan ; sameSide? ; if [pop]  {
push 0 ; return ; }
push $from ; coords ; set y0 [pop] ; set x0 [pop] ; push $to ; coords ; set y1 [pop] ; set x1 [pop] ; push $x1 ; push $x0 ; - ; dup ; set dx [pop] ; abs ; set adx [pop] ; push $y1 ; push $y0 ; - ; dup ; set dy [pop] ; abs ; set ady [pop] ; push $fromMan ; tolower ; push "n"  ; != ; push $adx ; not ; push $ady ; not ; or ; push $adx ; push $ady ; = ; or ; and ; if [pop]  {
push $x0 ; set x [pop] ; push $y0 ; set y [pop] ; 
while 1 {
push $x ; push $x1 ; != ; push $y ; push $y1 ; != ; or ; 
if {[pop]==0} break 
push $x ; push $x0 ; != ; push $y ; push $y0 ; != ; or ; push $x ; push $y ; square ; push $::board([pop]) ; push "."  ; != ; and ; if [pop]  {
push 0 ; return ; }
push $dx ; sgn ; set x [expr {$x+[pop]}] ; push $dy ; sgn ; set y [expr {$y+[pop]}] ; }
}
push $fromMan ; tolower ; switch [pop]  {
k   { push $adx ; push 2 ; < ; push $ady ; push 2 ; < ; and ; return ;  }
q   { push $adx ; 0= ; push $ady ; 0= ; or ; push $adx ; push $ady ; = ; or ; return ;  }
b   { push $adx ; push $ady ; = ; return ;  }
n   { push $adx ; push 1 ; = ; push $ady ; push 2 ; = ; and ; push $adx ; push 2 ; = ; push $ady ; push 1 ; = ; and ; or ; return ;  }
r   { push $adx ; 0= ; push $ady ; 0= ; or ; return ;  }
}
push $fromMan ; switch [pop]  {
P   { push $y0 ; push 2 ; = ; push $dy ; push 2 ; = ; and ; push $dy ; push 1 ; = ; or ; push $dx ; 0= ; push $toMan ; push "."  ; = ; and ; and ; push $adx ; push 1 ; = ; push $ady ; push 1 ; = ; and ; push "p"  ; push $toMan ; sameSide? ; and ; or ; return ;  }
p   { push $y0 ; push 7 ; = ; push $dy ; push -2 ; = ; and ; push $dy ; push -1 ; = ; or ; push $dx ; 0= ; push $toMan ; push "."  ; = ; and ; and ; push $adx ; push 1 ; = ; push $ady ; push 1 ; = ; and ; push "P"  ; push $toMan ; sameSide? ; and ; or ; return ;  }
}
push 0 ; set res [pop] ;  push $res ;  
} 

proc validMoves {} {
set from [pop] ;  set to 0 ;  set move 0 ;  set victim 0 ;  
push {} ; set result [pop] ; push [array names ::board] ; push { to }  ; foreach [pop] [pop] {
push "$from-$to"  ; set move [pop] ; push $move ; valid? ; if [pop]  {
push $to ; push $::board([pop]) ; set victim [pop] ; push "-$victim"  ; append move [pop] ; push $move ; lappend result [pop] ; }
}
set result [lsort $result] ;  push $result ;  
} 

proc coords {} {
set square [pop] ;  
push {} ; push $square ;  foreach {j} [split [pop] [pop]] {push $j} ; set y [pop] ; ascii ; push 64 ; - ; set x [pop] ;  push $x ;  push $y ;  
} 

proc square {} {
set y [pop] ;  set x [pop] ;  
push $x ; push 64 ; + ; char ; set x [pop] ; push "$x$y"  ; set sq [pop] ;  push $sq ;  
} 

push { k king q queen b bishop n knight r rook p pawn  }  ; array set Name [pop] ; 

push { k 0 q 9 b 3.2 n 3 r 5 p 1 . 0 }  ; array set Value [pop] ; 

proc values {} {
set square 0 ;  set man 0 ;  set whitesum 0 ;  set blacksum 0 ;  
push [array names ::board] ; push { square }  ; foreach [pop] [pop] {
push $square ; push $::board([pop]) ; set man [pop] ; push $man ; tolower ; push $::Value([pop]) ; push $man ; color ; push $::white ; = ; if [pop]  {
set whitesum [expr {$whitesum+[pop]}] ; } else {
set blacksum [expr {$blacksum+[pop]}] ; }
}
push "w:$whitesum  b:$blacksum "  ; set res [pop] ;  push $res ;  
} 

push ".c"  ; set w [pop] ; 

push 0 ; set X [pop] ; 

push 0 ; set Y [pop] ; 

push { bisque tan3  }  ; set cColors [pop] ; 

proc manPolygon {} {
set what [pop] ;  
push $what ; tolower ; switch [pop]  {
b   { push { -10 8  -5 5  -9 0  -6 -6  0 -10  6 -6  9 0  5 5  10 8  
		6 10  0 6  -6 10  }  ;  }
k   { push { -8 10  -10 1  -3 -1  -3 -3  -6 -3  -6 -7  -3 -7  -3 -10
		3 -10  3 -7  6 -7  6 -3  3 -3  3 -1  10 1  8 10  }  ;  }
n   { push { -8 10  -1 -1  -7 0  -10 -4  0 -10  6 -10  10 10  }  ;  }
p   { push { -8 10  -8 7  -5 7  -2 -1  -4 -5  -2 -10  2 -10  4 -5 
   		2 -1  5 7  8 7  8 10  }  ;  }
r   { push { -10 10  -7 1  -10 0  -10 -10  -5 -10  -5 -6  -3 -6  -3 -10
   		3 -10  3 -6  5 -6  5 -10  10 -10 10 0  7 1  10 10  }  ;  }
q   { push { -6 10  -10 -10  -3 0  0 -10  3 0  10 -10  6 10  }  ;  }
}
set shape [pop] ;  push $shape ;  
} 

push 35 ; set sqw [pop] ; 

proc drawMan {} {
set what [pop] ;  set where [pop] ;  set f 0 ;  set fill 0 ;  set shape 0 ;  set x0 0 ;  set y0 0 ;  set x1 0 ;  set y1 0 ;  
push $what ; push "."  ; = ; if [pop]  {
return ; }
push $::w ; push $what ; manPolygon ; push $what ; uppercase? ; if [pop]  {
push $::white ; push "black"  ; } else {
push $::black ; push "grey"  ; }
push "mv @$where"  ; createPoly ; push $::sqw ; push 0.035 ; * ; set f [pop] ; push $::w ; push "@$where"  ; push 0 ; push 0 ; push $f ; push $f ; scaleTag ; push $::w ; push "$where"  ; tagBox ; set y1 [pop] ; set x1 [pop] ; set y0 [pop] ; set x0 [pop] ; push $::w ; push "@$where"  ; push $x0 ; push $x1 ; + ; push 2 ; / ; push $y0 ; push $y1 ; + ; push 2 ; / ; moveTag ;   
} 

proc bindBoard {} { 
set w [pop] ;  
	bind $w <Configure> "push $w; drawBoard "
	$w bind mv <1> "push $w; push %x; push %y; click1 "
	$w bind mv <B1-Motion> {
		%W move current [expr {%x-$::X}] [expr {%y-$::Y}]
		set ::X %x; set ::Y %y
	}
	$w bind mv <ButtonRelease-1> "push $w; push %x; push %y; release1 " 
 } 

proc drawBoard {} {
set x0 0 ;  set x 0 ;  set y 0 ;  set rows 0 ;  set row 0 ;  set cols 0 ;  set col 0 ;  set cIndex 0 ;  set tag 0 ;  
push $::w ; windowExists ; if [pop]  {
push $::w ; push "all"  ; deleteTags ; } else {
push $::w ; createCanvas ; push $::w ; bindBoard ; }
push 15 ; set x0 [pop] ; push $x0 ; set x [pop] ; push 5 ; set y [pop] ; push 0 ; set cIndex [pop] ; push 35 ; set ::sqw [pop] ; push { 8 7 6 5 4 3 2 1  }  ; set rows [pop] ; push { A B C D E F G H  }  ; set cols [pop] ; push $::side ; push $::white ; != ; if [pop]  {
set rows [lrevert $rows] ; set cols [lrevert $cols] ; }
push $rows ; push { row }  ; foreach [pop] [pop] {
push $::w ; push 5 ; push $y ; push $::sqw ; push 2 ; / ; + ; push $row ; createText ; push $cols ; push { col }  ; foreach [pop] [pop] {
push $::w ; push $x ; push $y ; push $::sqw ; set x [expr {$x+[pop]}] ; push $x ; push $y ; push $::sqw ; + ; push $cIndex ; @list $::cColors [pop] ; push "square $col$row"  ; createRect ; push 1 ; push $cIndex ; - ; set cIndex [pop] ; }
push $x0 ; set x [pop] ; push $::sqw ; set y [expr {$y+[pop]}] ; push 1 ; push $cIndex ; - ; set cIndex [pop] ; }
push $x0 ; push $::sqw ; push 2 ; / ; - ; set x [pop] ; push 8 ; set y [expr {$y+[pop]}] ; push $cols ; push { col }  ; foreach [pop] [pop] {
push $::sqw ; set x [expr {$x+[pop]}] ; push $::w ; push $x ; push $y ; push $col ; createText ; }
push $::w ; drawSetup ;   
} 

push 0 ; set info [pop] ; 

proc MoveInfo {} {
set v 0 ;  
push "$::toMove to move - [values; pop]"  ; set ::info [pop] ;   
} 

proc doMoveInfo {- - -} {
	MoveInfo
}

proc theBoard {} { 
    frame .f
    label  .f.e -width 30 -anchor w -textvar info -relief sunken
    button .f.u -text Undo  -command {undo; push .c; drawSetup }
    button .f.r -text Reset -command {reset; push .c; drawSetup}
    button .f.f -text Flip  -command {push .c; flipSides}
    eval pack [winfo children .f] -side left -fill both
    pack .f -fill x -side bottom
    pack .c -fill both -expand 1
    trace add variable ::toMove write doMoveInfo 
    bind . ?        {console show}
    bind . <Escape> {exit}
    set ::info "white to move"
    wm title . "Chess in Forth" 
 } 

proc drawChess {} {
push $::w ; destroy [pop]; push ".f"  ; destroy [pop]; reset ; drawBoard ; theBoard ;   
} 

proc getFrom {} { 
set w [pop] ;  
	$w raise current
	regexp {@(..)} [$w gettags current] -> from 
push $from ;  } 

push 0 ; set From [pop] ; 

proc click1 {} {
set cy [pop] ;  set cx [pop] ;  set w [pop] ;  set fill 0 ;  set move 0 ;  set victim 0 ;  set to 0 ;  set fill 0 ;  set newfill 0 ;  
push $cx ; set ::X [pop] ; push $cy ; set ::Y [pop] ; push $w ; getFrom ; set ::From [pop] ; push $::From ; validMoves ; push { move }  ; foreach [pop] [pop] {
push { - }  ; push $move ;  foreach {j} [split [pop] [pop]] {push $j} ; set victim [pop] ; set to [pop] ; drop ; push $w ; push $to ; push "-fill"  ; ItemGet ; set fill [pop] ; push $fill ; push "green"  ; != ; push $fill ; push "red"  ; != ; and ; if [pop]  {
push $victim ; push "."  ; = ; if [pop]  {
push "green"  ; } else {
push "red"  ; }
set newfill [pop] ; push $w ; push $to ; push "-fill"  ; push $newfill ; ItemPut ; push "$w itemconfigure $to -fill $fill"  ; push 1000 ;  after [pop] [pop] ;  }
}
  
} 

proc release1 {} {
set cy [pop] ;  set cx [pop] ;  set w [pop] ;  set to 0 ;  set i 0 ;  set tags 0 ;  set victim 0 ;  set target 0 ;  set x0 0 ;  set y0 0 ;  set x1 0 ;  set y1 0 ;  set xm0 0 ;  set ym0 0 ;  set xm1 0 ;  set ym1 0 ;  
push {} ; set to [pop] ; push $w ; push "overlap $cx $cy $cx $cy"  ; canvasFind ; push { i  }  ; foreach [pop] [pop] {
push $w ; push $i ; getTags ; set tags [pop] ; push "square"  ; push [lsearch $tags [pop]] ; push 0 ; >= ; if [pop]  {
push [lindex $tags end]; set tags [lreplace $tags end end] ; set to [pop] ; break ; }
}
push "$::From-$to"  ; valid? ; if [pop]  {
push "$::From-$to"  ; moveMan ; set victim [pop] ; push $victim ; tolower ; push "k"  ; = ; if [pop]  {
push "Checkmate"  ; set ::info [pop] ; }
push $w ; push "@$to"  ; deleteTags ; push $w ; push "current"  ; push "@$::From"  ; DTags ; push $w ; push "@$to"  ; push "withtag"  ; push "current"  ; addTag ; push $to ; set target [pop] ; } else {
push $::From ; set target [pop] ; }
push $w ; push $target ; tagBox ; set y1 [pop] ; set x1 [pop] ; set y0 [pop] ; set x0 [pop] ; push $w ; push "current"  ; tagBox ; set ym1 [pop] ; set xm1 [pop] ; set ym0 [pop] ; set xm0 [pop] ; push $w ; push "current"  ; push $x0 ; push $x1 ; + ; push $xm0 ; - ; push $xm1 ; - ; push 2 ; / ; push $y0 ; push $y1 ; + ; push $ym0 ; - ; push $ym1 ; - ; push 2 ; / ; moveTag ;   
} 

proc drawSetup {} {
set w [pop] ;  set x 0 ;  set y 0 ;  
push $w ; push "mv"  ; deleteTags ; push 9 ; push 1 ; set start1 [pop]; set limit1 [pop]; set incr1 1
	for {set _i1 $start1} {$_i1 < $limit1 } {incr _i1 $incr1  } {
push 9 ; push 1 ; set start2 [pop]; set limit2 [pop]; set incr2 1
	for {set _i2 $start2} {$_i2 < $limit2 } {incr _i2 $incr2  } {
push $_i2; set y [pop] ; push $_i1; push 64 ; + ; char ; set x [pop] ; push "$x$y"  ; dup ; push $::board([pop]) ; drawMan ; }
}
  
} 

proc undo {} {
set from 0 ;  set to 0 ;  set hit 0 ;  
push [llength $::history] ; 0= ; if [pop]  {
push "Nothing to undo"  ; ErrorMsg ; }
push "-"  ; push [lindex $::history end]; set ::history [lreplace $::history end end] ;  foreach {j} [split [pop] [pop]] {push $j} ; set hit [pop] ; set to [pop] ; set from [pop] ; push $to ; push $::board([pop]) ; push $from ; set ::board([pop]) [pop] ; push $hit ; push {} ; = ; if [pop]  {
push "."  ; } else {
push $hit ; }
push $to ; set ::board([pop]) [pop] ; push $::toMove ; push $::white ; = ; if [pop]  {
push $::black ; } else {
push $::white ; }
set ::toMove [pop] ;   
} 

proc flipSides {} {
set w [pop] ;  
push $w ; push "all"  ; deleteTags ; push $::side ; push $::white ; = ; if [pop]  {
push $::black ; } else {
push $::white ; }
set ::side [pop] ; push $w ; drawBoard ;   
} 

drawChess ; 



