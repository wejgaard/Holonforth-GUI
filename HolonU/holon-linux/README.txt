Welcome to Holon. Just a few notes:

INSTALLATION

When you read this, Holon is already installed. There is nothing to set up.
(To get rid of Holon, simply delete the Holon directory.)


SYSTEM

There are three system files.

- tclkit -- is the brilliant selfcontained Tcl system that made Holon possible.

	(Tclkit is a product of equi4, see http://www.equi4.com/tclkit/index.html)

- holon.kit -- contains the Holon system that is loaded into Tcl.

- source/holon.hdb -- is the project database of this demo Holon system. 


RUN HOLON

Start Holon in the Terminal: 

	cd Desktop/holon-linux          (adapt your actual holon directory)
	
	chmod 700 tclkit
	
	./tclkit holon.kit holon.hdb


NOTES


1. Holon creates an external source file for every module in the project. 

2. The source files are always up-to-date. 

3. The source directory contains the state of the project. Easy to backup. 

4. The Tcl system tclkit is used both for the development system and for 
the application. The application runs in a separate instance of tclkit. 


The user's guide in Holon has more information. 

--

Wolf Wejgaard
wolf@holonforth.com


