proc raisecurrent {} { 
set w [pop] ;  
	$w raise current 
 } 

proc windowExists {} { 
set w [pop] ;  
	set flag [winfo exists $w] 
push $flag ;  } 

proc createCanvas {} { 
set w [pop] ;  
	canvas $w -width 300 -height 300 
 } 

proc createRect {} { 
set tag [pop] ;  set color [pop] ;  set y2 [pop] ;  set x2 [pop] ;  set y1 [pop] ;  set x1 [pop] ;  set w [pop] ;  
	$w create rect $x1 $y1 $x2 $y2 -fill $color -tag $tag 
 } 

proc createText {} { 
set t [pop] ;  set y [pop] ;  set x [pop] ;  set w [pop] ;  
	$w create text $x $y -text $t 
 } 

proc createPoly {} { 
set tag [pop] ;  set outline [pop] ;  set color [pop] ;  set polygon [pop] ;  set w [pop] ;  
	$w create poly $polygon -fill $color -tag $tag -outline $outline 
 } 

proc tagBox {} { 
set tag [pop] ;  set w [pop] ;  
	foreach {x0 y0 x1 y1} [$w bbox $tag] break 
push $x0 ;  push $y0 ;  push $x1 ;  push $y1 ;  } 

proc moveTag {} { 
set dy [pop] ;  set dx [pop] ;  set tag [pop] ;  set w [pop] ;  
	$w move $tag $dx $dy 
 } 

proc ItemGet {} { 
set field [pop] ;  set tag [pop] ;  set w [pop] ;  
	set value [$w itemcget $tag $field] 
push $value ;  } 

proc ItemPut {} { 
set value [pop] ;  set field [pop] ;  set tag [pop] ;  set w [pop] ;  
	$w itemconfigure $tag $field $value 
 } 

proc canvasFind {} { 
set args [pop] ;  set w [pop] ;  
	set list [eval $w find $args] 
push $list ;  } 

proc deleteTags {} { 
set tag [pop] ;  set w [pop] ;  
	$w delete $tag 
 } 

proc DTags {} { 
set delete [pop] ;  set tag [pop] ;  set w [pop] ;  
	$w dtag $tag $delete 
 } 

proc addTag {} { 
set where [pop] ;  set how [pop] ;  set tag [pop] ;  set w [pop] ;  
	$w addtag $tag $how $where 
 } 

proc getTags {} { 
set i [pop] ;  set w [pop] ;  
	set tags [$w gettags $i] 
push $tags ;  } 

proc scaleTag {} { 
set ys [pop] ;  set xs [pop] ;  set y [pop] ;  set x [pop] ;  set tag [pop] ;  set w [pop] ;  
	$w scale $tag $x $y $xs $ys 
 } 



