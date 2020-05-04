\name{getSocketServerName}
\alias{getSocketServerName}

\title{ Get the name of a R socket server }

\description{
  Get the internal name given to a particular R socket server.
}

\usage{
getSocketServerName(port = 8888)
}

\arguments{
  \item{port}{ the port of the R socket server. }
}

\value{
  A string with the server name, or \code{NULL} if it does not exist.
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link{getSocketServers}} }

\keyword{ IO }
\keyword{ utilities }

\concept{ stateful socket server interprocess communication }
