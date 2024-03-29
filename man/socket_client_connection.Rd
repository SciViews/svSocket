% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/socket_client_connection.R
\name{socket_client_connection}
\alias{socket_client_connection}
\alias{summary.sockclientconn}
\alias{socketClientConnection}
\title{Open a connection to a SciViews socket client for write access}
\usage{
socket_client_connection(
  client,
  server_port = 8888,
  socket,
  blocking = FALSE,
  open = "a",
  encoding = getOption("encoding")
)

\method{summary}{sockclientconn}(object, ...)

socketClientConnection(
  client,
  server_port = 8888,
  socket,
  blocking = FALSE,
  open = "a",
  encoding = getOption("encoding")
)
}
\arguments{
\item{client}{the client identification. By default, it is the socket
identifier as it appears in \code{\link[=get_socket_clients]{get_socket_clients()}}. The client must be
currently connected.}

\item{server_port}{the port on which the server is running, 8888 by default.
This server must be currently running.}

\item{socket}{the Tcl socket name where the targeted client is connected. If
not provided, it will be guessed from \code{client}, otherwise, \code{client} is
ignored.}

\item{blocking}{logical. Should the connection wait that the data is written
before exiting?}

\item{open}{character. How the connection is opened. Currently, only \code{"a"}
for append (default) or \code{"w"} for write access are usable.}

\item{encoding}{the name of the encoding to use.}

\item{object}{A 'sockclientconn' object as returned by
\code{\link[=socket_client_connection]{socket_client_connection()}}.}

\item{...}{further arguments passed to the method (not used for the moment).}
}
\value{
\code{\link[=socket_client_connection]{socket_client_connection()}} creates a 'sockclientconn' object redirects text
send to it to the SciViews socket server client. It is inherits from a
'sockconn' object (see \code{socketConnection()}), and the only difference is that
output is redirected to a Tcl socket corresponding to a given SciViews socket
client currently connected.
}
\description{
A 'sockclientconn' object is created that opens a connection from R to a
SciViews socket client (that must be currently connected). A timeout is
defined by \code{options(timeout = XX)} where \code{XX} is a number of seconds. In R,
its default value is 60 sec.
}
\seealso{
\code{\link[=socketConnection]{socketConnection()}}, \code{\link[=send_socket_clients]{send_socket_clients()}}
}
\concept{stateful socket server interprocess communication}
\keyword{IO}
\keyword{utilities}
