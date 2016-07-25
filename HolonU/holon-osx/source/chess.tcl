namespace eval chess {set version 0.2 ;# resize on <Configure>}

proc chess::new board {
    # create a new game (generic dispatcher) with the board name
    proc ::$board {{cmd format} args} \
        "uplevel 1 chess::\$cmd $board \$args"
    uplevel 1 $board reset
 }

proc chess::reset {boardName {setup ""}} {
    upvar 1 $boardName board
    if {$setup == ""} {set setup \
        "r n b q k b n r
         p p p p p p p p
         . . . . . . . .
         . . . . . . . .
         . . . . . . . .
         . . . . . . . .
         P P P P P P P P
         R N B Q K B N R"
    }
    foreach line [split [string trim $setup] \n] y {8 7 6 5 4 3 2 1} {
        foreach word $line x {A B C D E F G H} {
            set board($x$y) $word
        }
    }
    set board(toMove) white
    set board(history) {} ;# start a new history...
 }

proc chess::format boardName {
    upvar 1 $boardName board
    foreach row {8 7 6 5 4 3 2 1} {
        foreach column {A B C D E F G H} {
            append res " " $board($column$row)
        }
        append res \n
    }
    set res
 }

proc chess::move {boardName move} {
    upvar 1 $boardName board
    foreach {from to} [split $move -] break
    set fromMan $board($from)
    if {$fromMan == "."} {error "no man to move at $from"}
    set toMan   $board($to)
    if ![valid? board $move] {error "invalid move for a [manName $fromMan]"}
    set board($from) .
    set board($to)   $fromMan
    if {$toMan != "."} {append move -$toMan} ;# taken one
    lappend board(history) $move
    set board(toMove) [expr {$board(toMove) == "white"? "black": "white"}]
    set toMan ;# report possible victim
 }

proc chess::color man {
	expr {[string is upper $man]? "white" : "black"}
}

proc chess::valid? {boardName move} {
    upvar 1 $boardName board
    foreach {from to} [split $move -] break
    if {$to==""} {return 0}
    set fromMan $board($from)
    if {[color $fromMan] != $board(toMove)} {return 0}
    set toMan   $board($to)
    if [sameSide $fromMan $toMan] {return 0}
    foreach {x0 y0} [coords $from] {x1 y1} [coords $to] break
    set dx  [expr {$x1-$x0}]
    set adx [expr {abs($dx)}]
    set dy  [expr {$y1-$y0}]
    set ady [expr {abs($dy)}]
    if {[string tolower $fromMan] != "n" && (!$adx || !$ady || $adx==$ady)} {
        for {set x $x0; set y $y0} {($x!=$x1 || $y!=$y1)} \
          {incr x [sgn $dx]; incr y [sgn $dy]} {
            if {($x!=$x0 || $y!=$y0) && $board([square $x $y])!="."} {
                return 0
            } ;# planned path is blocked
        }
    }
    switch -- $fromMan {
        K - k {expr $adx<2 && $ady<2}
        Q - q {expr $adx==0 || $ady==0 || $adx==$ady}
        B - b {expr $adx==$ady}
        N - n {expr ($adx==1 && $ady==2)||($adx==2 && $ady==1)}
        R - r {expr $adx==0 || $ady==0}
        P {
            expr {(($y0==2 && $dy==2) || $dy==1)
              && (($dx==0 && $toMan==".") ||
                ($adx==1 && $ady==1 && [sameSide p $toMan]))
            }
        }
        p {
            expr {(($y0==7 && $dy==-2) || $dy==-1)
              && (($dx==0 && $toMan==".") ||
                ($adx==1 && $ady==1 && [sameSide P $toMan]))
            }
        }
        default {return 0}
    }
 }

proc chess::validMoves {boardName from} {
    upvar 1 $boardName board
    set res {}
    foreach to [array names board ??] {
        set move $from-$to
        if [valid? board $move] {
            if {$board($to) != "."} {append move -$board($to)}
            lappend res $move
        }
    }
    lsort $res
 }

proc chess::coords square {
    foreach {c y} [split $square ""] break
    list [lsearch {- A B C D E F G H} $c] $y
 }

proc chess::square {x y} {
    return [string map {1 A 2 B 3 C 4 D 5 E 6 F 7 G 8 H} $x]$y
 }

proc chess::manValue man {
    array set a {k 0 q 9 b 3.2 n 3 r 5 p 1}
    set a([string tolower $man])
 }

proc chess::values boardName {
    upvar 1 $boardName board
    set white 0; set black 0
    foreach square [array names board ??] {
        set man $board($square)
        switch -regexp -- $man {
            [A-Z] {set white [expr {$white + [manValue $man]}]}
            [a-z] {set black [expr {$black + [manValue $man]}]}
        }
    }
    list w:$white b:$black
 }

proc chess::manName man {
    set table {- k king q queen b bishop n knight r rook p pawn}
    set i [lsearch $table [string tolower $man]]
    lindex $table [incr i]
 }

proc chess::history boardName {
	uplevel 1 set $boardName\(history)
}

proc chess::sameSide {a b} {
	regexp {[a-z][a-z]|[A-Z][A-Z]} $a$b]
}

proc chess::undo boardName {
    upvar 1 $boardName board
    if ![llength $board(history)] {error "Nothing to undo"}
    set move [lindex $board(history) end]
    foreach {from to hit} [split $move -]  break
    set board(history) [lrange $board(history) 0 end-1]
    set board($from) $board($to)
    if {$hit==""} {set hit .}
    set board($to) $hit
    set board(toMove) [expr {$board(toMove) == "white"? "black": "white"}]
 }

proc chess::drawBoard {boardName w args} {
    upvar #0 $boardName board
    array set opt {-width 300 -colors {bisque tan3} -side white -usefont 0}
    array set opt $args
    if {![winfo exists $w]} {
        canvas $w -width $opt(-width) -height $opt(-width) 
        bind $w <Configure> "chess::drawBoard $boardName $w $args"
        set board(usefont) $opt(-usefont)
        $w bind mv <1> [list chess::click1 $boardName $w %x %y]
        $w bind mv <B1-Motion> {
            %W move current [expr {%x-$chess::x}] [expr {%y-$chess::y}]
            set chess::x %x; set chess::y %y
        }
        $w bind mv <ButtonRelease-1> "chess::release1 $boardName $w %x %y"
    } else {
        $w delete all
    }
    set board(side)   $opt(-side)
    set dim [min [winfo height $w] [winfo width $w]]
    if {$dim<2} {set dim $opt(-width)}
    set board(sqw) [set sqw [expr {($dim - 20) / 8}]]
    set x0 15
    set x $x0; set y 5; set colorIndex 0
    set rows {8 7 6 5 4 3 2 1}
    set cols {A B C D E F G H}
    if {$board(side) != "white"} {
        set rows [lrevert $rows]
        set cols [lrevert $cols]
    }
    foreach row $rows {
        $w create text 5 [expr {$y+$sqw/2}] -text $row
        foreach col $cols {
            $w create rect $x $y [incr x $sqw] [expr $y+$sqw] \
                -fill [lindex $opt(-colors) $colorIndex] \
                -tag [list square $col$row]
            set colorIndex [expr {1-$colorIndex}]
        }
        set x $x0; incr y $sqw
        set colorIndex [expr {1-$colorIndex}]
    }
    set x [expr {$x0 - $sqw/2}]
    incr y 8 ;# letters go below chess board
    foreach col $cols {$w create text [incr x $sqw] $y -text $col}
    drawSetup $boardName $w
    set w
 }

proc chess::click1 {boardName w cx cy} {
    upvar #0 $boardName board
    variable x $cx y $cy from
    $w raise current
    regexp {@(..)} [$w gettags current] -> from
    foreach move [validMoves board $from] {
        foreach {- to victim} [split $move -] break
        set fill [$w itemcget $to -fill]
        if {$fill != "green" && $fill != "red"} {
            set newfill [expr {$victim==""? "green" : "red"}]
            $w itemconfig $to -fill $newfill
            after 1000 $w itemconfig $to -fill $fill
        }
    }
 }

proc chess::release1 {boardName w cx cy} {
    upvar #0 $boardName board
    variable from
    set to ""
    foreach i [$w find overlap $cx $cy $cx $cy] {
        set tags [$w gettags $i]
        if {[lsearch $tags square]>=0} {
            set to [lindex $tags end]
            break
        }
    }
    if [valid? board $from-$to] {
        set victim [move board $from-$to]
        if {[string tolower $victim]=="k"} {set ::info Checkmate.}
        $w delete @$to
        set target $to
        $w dtag current @$from
        $w addtag @$to withtag current
    } else {set target $from} ;# go back on invalid move
    foreach {x0 y0 x1 y1}     [$w bbox $target] break
    foreach {xm0 ym0 xm1 ym1} [$w bbox current] break
    set dx [expr {($x0+ $x1-$xm0-$xm1)/2}]
    set dy [expr {($y0+$y1-$ym0-$ym1)/2}]
    $w move current $dx $dy
 }

proc chess::drawSetup {boardName w} {
    upvar #0 $boardName board
    $w delete mv
    foreach square [array names board ??] {
        drawMan $boardName $w $square $board($square)
    }
 }

proc chess::drawMan {boardName w where what} {
    if {$what=="."} return
    upvar #0 $boardName board
    set fill [expr {[regexp {[A-Z]} $what]? "white": "black"}]
    if $board(usefont) {
        set unicode [string map {
            k \u265a q \u265b r \u265c b \u265d n \u265e p \u265f
          k K q Q r R b B n N p P
        } [string tolower $what]]
        set font [list Helvetica [expr {$board(sqw)/2}] bold]
        $w create text 0 0 -text $unicode -font $font \
            -tag [list mv @$where] -fill $fill
    } else {
        $w create poly [manPolygon $what] -fill $fill \
            -tag [list mv @$where] -outline gray
        set f [expr {$board(sqw)*0.035}]
        $w scale @$where 0 0 $f $f
    }
    foreach {x0 y0 x1 y1} [$w bbox $where] break
    $w move  @$where [expr {($x0+$x1)/2}] [expr {($y0+$y1)/2}]
 }

proc chess::manPolygon what {
    # very simple shapes of the chess men - feel free to improve!
    switch -- [string tolower $what] {
     b {list -10 8  -5 5  -9 0  -6 -6  0 -10  6 -6  9 0  5 5  10 8\
        6 10  0 6  -6 10}
     k {list -8 10  -10 1  -3 -1  -3 -3  -6 -3  -6 -7  -3 -7  -3 -10\
        3 -10  3 -7  6 -7  6 -3  3 -3  3 -1  10 1  8 10}
     n {list -8 10  -1 -1  -7 0  -10 -4  0 -10  6 -10  10 10}
     p {list -8 10  -8 7  -5 7  -2 -1  -4 -5  -2 -10  2 -10  4 -5 \
          2 -1  5 7  8 7  8 10}
     q {list -6 10  -10 -10  -3 0  0 -10  3 0  10 -10  6 10}
     r {list -10 10  -7 1  -10 0  -10 -10  -5 -10  -5 -6  -3 -6  -3 -10\
          3 -10  3 -6  5 -6  5 -10  10 -10 10 0  7 1  10 10}
    }
 }

proc chess::flipSides {boardName w} {
    upvar #0 $boardName board
    $w delete all
    set side [expr {$board(side)=="white"? "black": "white"}]
    $boardName drawBoard $w -side $side
 }

proc lrevert list {
    set res {}
    set i [llength $list]
    while {$i} {lappend res [lindex $list [incr i -1]]}
    set res
 }

proc min args {
	lindex [lsort -real $args] 0
}

proc sgn x {
	expr {$x>0? 1: $x<0? -1: 0}
}

proc MoveInfo {- - -} {
        set ::info "$::game(toMove) to move - [chess::values ::game]"
}

chess::new game
    frame .f
    label  .f.e -width 30 -anchor w -textvar info -relief sunken
    button .f.u -text Undo  -command {game undo;  game drawSetup .c}
    button .f.r -text Reset -command {game reset; game drawSetup .c}
    button .f.f -text Flip  -command {game flipSides .c}
    eval pack [winfo children .f] -side left -fill both
    pack .f -fill x -side bottom
    pack [game drawBoard .c] -fill both -expand 1
    trace variable game(toMove) w MoveInfo
    bind . <3> {
        set game(usefont) [expr 1-$game(usefont)]
        event generate .c <Configure>
    }
    bind . ?        {console show}
    bind . <Escape> {exec wish $argv0 &; exit}
    set info "white to move"
    wm title . "Chess in Tcl"

