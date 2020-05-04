\name{sendSocketClients}
\alias{sendSocketClients}

\title{ Send data to one or more clients through a socket }

\description{
  The text is send to one or more clients of the R socket server currently
  connected.
}

\usage{
sendSocketClients(text, sockets = "all", serverport = 8888)
}

\arguments{
  \item{text}{ the text to send to the client(s). }
  \item{sockets}{ the Tcl name of the client(s) socket(s) currently connected
    (sockXXX), or "all" (by default) to send the same text to all connected
    clients. }
  \item{serverport}{ the port of the server considered. }
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link{closeSocketClients}}, \code{\link{processSocket}} }

\examples{
\dontrun{
## Start an R process (R#1) and make it a server
require(svSocket)
serverport <- 8888  # Port 8888 by default, but you can change it
startSocketServer(port = serverport)


## Start a second R process (R#2) and run this code in it (the R client):
require(svSocket)
## Connect with the R socket server
con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)


## Now, go back to the server R#1
getSocketClients() # You should have one client registered
## Send something to all clients from R#1
sendSocketClients("Hi there!")


## Switch back to client R#2
## Since the connection is not blocking, you have to read lines actively
readLines(con)
## Note the final empty string indicating there is no more data
close(con) # Once done...


## Switch to the R#1 server and close the server
stopSocketServer(port = serverport)
}
}

\keyword{ IO }

\concept{ stateful socket server interprocess communication }
