proc Monitor {{port 3456}} {
	catch {socket -server MonitorReceive $port}
 }
 
Monitor

proc MonitorReceive {socket adr port} {
    fileevent $socket readable [list MonitorExecute $socket]
 }

proc MonitorExecute {sock} {
	global source scon
	set scon $sock   ;# channel for output to console
     set source ""
     gets $sock line
     while {$line!=""} {
     		append source $line\n
     		gets $sock line
 	}
 	append source "\n"
	catch {uplevel #0 {eval $source}} res
	puts $sock $res
	if [catch {flush $sock}] {close $sock}
 }


package require Tk

set con target
if [catch {console show}] {set con host}
catch {console title "Target console"}


source _forth.tcl
source _tk.tcl
source chess.tcl



