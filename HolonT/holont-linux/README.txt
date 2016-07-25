Welcome to HolonT. Just a few notes:


INSTALLATION

When you read this, HolonT is already installed. There is nothing to set up.
(To get rid of HolonT, delete the HolonT directory.)


SYSTEM

There are three system files and a start utility:

- tclkit -- is the brilliant selfcontained Tcl system that made Holon possible.

	(Tclkit is a product of equi4, see http://www.equi4.com/tclkit/index.html)

- holont.kit -- contains the HolonT system that is loaded into Tcl.

- source/holont.hdb -- is the project database of this demo HolonT system. 


RUN HOLONT

Start HolonT in the terminal: 

	cd Desktop/holont-linux          (adapt to your actual holont directory)

	chmod 700 tclkit

	chmod 700 startholon

	./tclkit holont.kit holont.hdb

Next Start:

	Double-click the file startholon
	
	
	

NOTES

The Tcl system tclkit is used both for the development system and for 
the application. The application runs in a separate instance of tclkit. 


The user's guide in Holon has more information. 

--

Wolf Wejgaard
wolf@holonforth.com








	 
