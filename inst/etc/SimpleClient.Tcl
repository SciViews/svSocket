#!/usr/bin/tclsh
# Open a terminal and issue
# $ tclsh SimpleClient.tcl
# when the R socket server is running
# (Under Windows, you need to install ActiveTcl8.4 first;
# see http://www.activestate.com/Products/ActiveTcl/)

# These are parameters of the R socket server
set rsHost "localhost"	;# localhost only (take care of security otherwise!)
set rsPort 8888		;# port is arbitrarily fixed at 8888 for the R server

# Read data from a channel (the R socket server) and put it into stdout
# this implements receiving and handling (viewing) a server reply
proc read_sock {sock} {
  if {[eof $sock] == 1 || [catch {gets $sock l}] || $l == "\f"} {
    fileevent $sock readable {}
    close $sock
    # puts "\nR socket server closed!"
    global eventLoop
    set eventLoop "done"
  } else {
    foreach {out in} [split $l "\n"] {
      if {$out == "> " || $out == "+ "} {
        puts -nonewline stdout $out
        flush stdout
      } else {
        ### TODO: a special command to insert a string before the command line!
        puts stdout "$out"
      }
    }
  }
}

# Read a line of text from stdin and send it to the R socket server,
# on eof stdin closedown (ctrl-c) the R server client socket connection
# this implements sending a message to the Server.
proc read_stdin {wsock} {
  set l [gets stdin]
  if {[eof stdin] == 1} {
    fileevent $wsock readable {}
	close $wsock		;# close the socket client connection
	global eventLoop
    set eventLoop "done"	;# terminate the vwait (eventloop)
  } else {
	  puts $wsock $l	;# send the data to the server
  }
}

# Open the connection to the R socket server...
# this is a synchronous connection:
# The command does not return until the server responds to the
# connection request
set rsSock [socket $rsHost $rsPort]

if {[eof $rsSock] == 1} {
	close $rsSock		;# connection closed ... abort
} else {

	# Setup monitoring on the socket so that when there is data to be
	# read the proc "read_sock" is called
	fileevent $rsSock readable [list read_sock $rsSock]

	# configure channel modes
	# ensure the socket is line buffered so we can get a line of text
	# at a time (because that's what the server expects)...
	# Depending on your needs you may also want this unbuffered so
	# you don't block in reading a chunk larger than has been fed
	#  into the socket
	# i.e fconfigure $esvrSock -blocking off
	# but this requires some modifications in the R socket server!
	fconfigure $rsSock -buffering line

	# set up our keyboard read event handler:
	#   Vector stdin data to the socket
	fileevent stdin readable [list read_stdin $rsSock]

	# message indicating connection accepted and we're ready to go
	puts "Connected to R socket server"
	puts "...what you type should be send to R."
        puts "Paste only one line of code at a time."
	puts "   hit <CTRL-C> to close the connection."

	# wait for and handle either socket or stdin events...
	vwait eventLoop

	puts "\nConnection with R is closed!"
}
