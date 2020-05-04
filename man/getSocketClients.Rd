\name{getSocketClients}
\alias{getSocketClients}
\alias{getSocketClientsNames}

\title{ Get infos about socket clients }
\description{
  List all clients currently connected to a given R socket server, or their
  names (sockXXX).
}

\usage{
getSocketClients(port = 8888)
getSocketClientsNames(port = 8888)
}

\arguments{
  \item{port}{ the port of the R socket server. }
}

\value{
  \code{getSocketClients()} returns a vector of character string with the
  address of clients in the form XXX.XXX.XXX.XXX:YYY where XXX.XXX.XXX.XXX is
  their ip address and YYY is their port. For security reasons, only localhost
  clients (on the same machine) can connect to the socket server. Thus,
  XXX.XXX.XXX.XXX is ALWAYS 127.0.0.1. However, the function returns the full IP
  address, just in case of further extensions in the future. The name of these
  items equals the corresponding Tcl socket name.
  
  \code{getSocketClientsNames()} returns only a list of the socket client names.
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link{getSocketServers}} }

\keyword{ IO }
\keyword{ utilities }

\concept{ stateful socket server interprocess communication }
