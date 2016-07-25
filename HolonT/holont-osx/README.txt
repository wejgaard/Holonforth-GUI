Welcome to HolonT. Just a few notes:


INSTALLATION

When you read this, HolonT is already installed. There is nothing to set up.
(To get rid of HolonT, delete the HolonT directory.)


SYSTEM

There are three system files and a start utility.

- tclkit -- is the brilliant selfcontained Tcl system that made Holon possible.

	(Tclkit is a product of equi4, see http://www.equi4.com/tclkit/index.html)

- holont.kit -- contains the HolonT system that is loaded into Tcl.

- source/holont.hdb -- is the project database of this demo HolonT system. 


RUN HOLONT

- Double-click the file start.command. -- Usually this works, if not, or alternatively:

- Open the terminal and enter:

	cd desktop/holont-osx            (adapt to the actual holont directory)

	./tclkit ./holont.kit holont.hdb


NOTES

1. The way HolonT is started makes a difference:

- If tclkit is called indirectly via start.command, tclkit uses the Tcl/Tk console. 
You get separate consoles for development system and application.

- If tclkit is called in the terminal, the terminal is the console of the Tcl program. 
HolonT development system and application share the terminal console.

2. If you start HolonT and see the message "Holon is already running", although it isn't,
wait a couple more seconds and try again. And close HolonT with the red window-close button.

3. The Tcl system tclkit is used both for the development system and for 
the application. The application runs in a separate instance of tclkit.


The user's guide in Holon has more information. 

--

Wolf Wejgaard
wolf@holonforth.com



