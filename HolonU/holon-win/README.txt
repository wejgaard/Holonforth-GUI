Welcome to Holon. Just a few notes to ease the way.

INSTALLATION

When you read this, Holon is already installed. There is nothing to set up.
(To get rid of Holon, simply delete the Holon directory.)


SYSTEM

There are three system files and a start utility.

- tclkit.exe -- is the brilliant selfcontained Tcl system that made Holon possible.

	(Tclkit is a product of equi4, see http://www.equi4.com/tclkit/index.html)

- holon.kit -- contains the Holon system that is loaded into Tcl.

- source/holon.hdb -- is the project database of this demo Holon system. 


RUN HOLON

Double-click holon.bat.


NOTES

1. When Holon starts, it writes an external source file for every module in the project. 
The files are collected in the source directory.

2. The source files are always up-to-date. When you change a program unit, the change 
also is written to the file. 

3. The source directory contains the state of the project. Easy to backup. 

4. If you develop with Holon you will probaly use your own project database, 
say, myproject.hdb. Holon creates the database at the first start of the new project.

5. Adapt the start script for your project: 

	start tclkit.exe holon.kit myproject.hdb
	
6. The Tcl system tclkit.exe is used both for the development system and for 
the application. The application runs in a separate instance of tclkit.


The user's guide in Holon has more information. 

--

Wolf Wejgaard
wolf@holonforth.com


