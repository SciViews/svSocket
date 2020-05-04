\name{closeSocketClients}
\alias{closeSocketClients}

\title{ Close one or more clients currently connected }

\description{
  The socket servers asks to clients to nicely disconnect (possibly doing
  further process on their side). This function is used by
  \code{\link{stopSocketServer}}, but it can also be invoked manually to ask for
  disconnection of a particular client. Note that, in this case, the client
  still can decide not to disconnect! The code send to ask for client
  disconnection is: \code{\\f}.
}

\usage{
closeSocketClients(sockets = "all",  serverport = 8888)
}

\arguments{
  \item{sockets}{ the list of socket client names (sockXXX) to close, or "all"
      (by default) to disconnect all currently connected clients. }
  \item{serverport}{ the corresponding R socket server port. }
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link{sendSocketClients}} }

\keyword{ IO }

\concept{ stateful socket server interprocess communication }
