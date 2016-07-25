set par {}

proc pop {} {
	set r [lindex $::par end]
	set ::par [lreplace $::par end end]
	return $r 
}

proc push {p} {
	lappend ::par $p
}

proc .s {} { 
	pcon\n $::par 
 } 

proc !s {} { 
	set ::par ""
	pcon\n "" 
 } 

set ret {}

proc r> {} {
	set r [lindex $::ret end]
	set ::ret [lreplace $::ret end end]
	return $r 
}

proc >r {p} {
	lappend ::ret $p
}

proc .r {} { 
	foreach r $::ret {
		pcon "$r "
	}
	pcon\n "" 
 } 

proc !r {} { 
	set ::ret ""
	pcon\n "" 
 } 

proc dup {} { 
set n [pop] ;   
push $n ;  push $n ;  } 

proc swap {} { 
set n2 [pop] ;  set n1 [pop] ;   
push $n2 ;  push $n1 ;  } 

proc over {} { 
set n2 [pop] ;  set n1 [pop] ;   
push $n1 ;  push $n2 ;  push $n1 ;  } 

proc drop {} { 
set n2 [pop] ;  set n1 [pop] ;   
push $n1 ;  } 

proc nip {} { 
set n2 [pop] ;  set n1 [pop] ;   
push $n2 ;  } 

proc rot {} { 
set n3 [pop] ;  set n2 [pop] ;  set n1 [pop] ;   
push $n2 ;  push $n3 ;  push $n1 ;  } 

proc depth {} { 
	set n [llength $::par] 
push $n ;  } 

proc + {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr {$n1+$n2}] 
push $n3 ;  } 

proc 1+ {} { 
set n1 [pop] ;  
	set n2 [incr n1] 
push $n2 ;  } 

proc 1- {} { 
set n1 [pop] ;  
	set n2 [incr n1 -1] 
push $n2 ;  } 

proc - {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr {$n1-$n2}] 
push $n3 ;  } 

proc * {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr {$n1*$n2}] 
push $n3 ;  } 

proc / {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr {$n1/$n2}] 
push $n3 ;  } 

proc % {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr {$n1%$n2}] 
push $n3 ;  } 

proc int {} { 
set n1 [pop] ;  
	set n2 [expr int($n1)] 
push $n2 ;  } 

proc min {} { 
set n2 [pop] ;  set n1 [pop] ;  
	if {$n1<$n2} {set n $n1} {set n $n2} 
push $n ;  } 

proc max {} { 
set n2 [pop] ;  set n1 [pop] ;  
	if {$n1>$n2} {set n $n1} {set n $n2} 
push $n ;  } 

proc abs {} { 
set n1 [pop] ;  
	set n2 [expr abs($n1)] 
push $n2 ;  } 

proc sgn {} { 
set n1 [pop] ;  
	set n2 [expr {$n1>0? 1: $n1<0? -1: 0}] 
push $n2 ;  } 

proc or {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr $n1 || $n2] 
push $n3 ;  } 

proc and {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set n3 [expr $n1 && $n2] 
push $n3 ;  } 

proc not {} { 
set n1 [pop] ;  
	set n2 [expr {!$n1}] 
push $n2 ;  } 

proc == {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1==$n2}] 
push $flag ;  } 

proc = {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1==$n2}] 
push $flag ;  } 

proc >= {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1>=$n2}] 
push $flag ;  } 

proc <= {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1<=$n2}] 
push $flag ;  } 

proc < {} { 
set n2 [pop] ;  set n1 [pop] ;  
	push [expr {$n1<$n2}] 
 } 

proc > {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1>$n2}] 
push $flag ;  } 

proc != {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1!=$n2}] 
push $flag ;  } 

proc <> {} { 
set n2 [pop] ;  set n1 [pop] ;  
	set flag [expr {$n1!=$n2}] 
push $flag ;  } 

proc 0= {} { 
set n1 [pop] ;  
	set flag [expr {$n1==0}] 
push $flag ;  } 

proc 0< {} { 
set n1 [pop] ;  
	set flag [expr {$n1<0}] 
push $flag ;  } 

proc 0> {} { 
set n [pop] ;  
	set flag [expr {$n>0}] 
push $flag ;  } 

proc endchar {} { 
set s [pop] ;  
	set c [string index $s end] 
push $c ;  } 

proc tolower {} { 
set C [pop] ;  
	set c [string tolower $C] 
push $c ;  } 

proc uppercase? {} { 
set c [pop] ;  
	set f [regexp {[A-Z]} $c] 
push $f ;  } 

proc end {} { 
set list [pop] ;  
	set e [lindex $list end] 
push $e ;  } 

proc lrevert list {
	set res {}
	set i [llength $list]
	while {$i} {lappend res [lindex $list [incr i -1]]}
	return $res
 }

proc !list {obj i} {
	 upvar #0 $obj object
	 set object [lreplace $object $i $i [pop]]
}

proc @list {obj i} {
	push [lindex $obj $i]
}

proc pcon {text} {
	if {$::con=="host"} {
		puts $::scon $text
	} {
		puts -nonewline $text
	}
}

proc pcon\n {text} {
	if {$::con=="host"} {
		puts $::scon $text
	} {
		puts $text
	}
}

proc .t {} { 
set text [pop] ;  
	pcon $text 
 } 

proc cr {} { 
	pcon\n "" 
 } 

proc .cr {} { 
set text [pop] ;  
	pcon\n $text 
 } 

proc space {} { 
	pcon " " 
 } 

proc spaces {} {
set n [pop] ;  
push $n ; set _t [pop]; while {$_t>0} {
	incr _t -1; space ; }
  
} 

proc emit {} { 
set c [pop] ;  
	pcon [format %c $c] 
 } 

proc ascii {} { 
set c [pop] ;  
	binary scan $c "c" a 
push $a ;  } 

proc char {} { 
set a [pop] ;  
	set c [format %c $a] 
push $c ;  } 

proc ErrorMsg {} { 
set text [pop] ;   
	error $text 
 } 



