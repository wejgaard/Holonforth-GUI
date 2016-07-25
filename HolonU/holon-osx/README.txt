Welcome to Holon. Just a few notes:


INSTALLATION

When you read this, Holon is already installed. There is nothing to set up.
(To get rid of Holon, simply delete the Holon directory.)


SYSTEM

There are three system files and a start utility.

- tclkit -- is the brilliant selfcontained Tcl system that made Holon possible.

	(Tclkit is a product of equi4, see http://www.equi4.com/tclkit/index.html)

- holon.kit -- contains the Holon system that is loaded into Tcl.

- source/holon.hdb -- is the project database of this demo Holon system. 


RUN HOLON

- Double-click the file start.command. -- Usually this works. If not: 

- Open the terminal and enter:

	cd desktop/holon-osx            (adapt to the actual holon directory)

	./tclkit ./holon.kit holon.hdb


NOTES


1. To quit Holon close the Holon window with the red button, don't use command-Q.

Command-Q does no harm, but Holon's "double-start-avoidance-timer" is not reset and
you must wait 10 or more seconds for a new start of Holon.


2. The Tcl system tclkit is used both for the development system and for 
the application. The application runs in a separate instance of tclkit.


The user's guide in Holon has more information. 

--

Wolf Wejgaard
wolf@holonforth.com

