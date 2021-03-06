% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getSocket.R
\name{getSocketServerName}
\alias{getSocketServerName}
\title{Get the name of a R socket server}
\usage{
getSocketServerName(port = 8888)
}
\arguments{
\item{port}{the port of the R socket server.}
}
\value{
A string with the server name, or \code{NULL} if it does not exist.
}
\description{
Get the internal name given to a particular R socket server.
}
\seealso{
\code{\link[=getSocketServers]{getSocketServers()}}
}
\concept{stateful socket server interprocess communication}
\keyword{IO}
\keyword{utilities}
