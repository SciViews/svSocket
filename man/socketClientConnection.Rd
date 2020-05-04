\name{socketClientConnection}
\alias{socketClientConnection}
\alias{summary.sockclientconn}

\title{ Open a connection to a SciViews socket client for write access }

\description{
  A 'sockclientconn' object is created that opens a connection from R to a
  SciViews socket client (that must be currently connected).
}

\usage{
socketClientConnection(client, serverport = 8888, socket, blocking = FALSE,
    open = "a", encoding = getOption("encoding"))

\method{summary}{sockclientconn}(object, \dots)
}

\arguments{
  \item{client}{ the client identification. By default, it is the socket
    identifier as it appears in \code{getSocketClients()}. The client must be
    currently connecte. }
  \item{serverport}{ the port on which the server is running, 8888 by default.
    This server must be currently running. }
  \item{socket}{ the Tcl socket name where the targetted client is connected. If
    not provided, it will be guessed from \code{client}, otherwise,
    \code{client} is ignored. }
  \item{blocking}{ logical. Should the connection wait that the data is written
    before exiting? }
  \item{open}{ character. How the connection is opened. Currently, only
    \code{"a"} for append (default) or \code{"w"} for write access are usable. }
  \item{encoding}{ the name of the encoding to use. }
  \item{object}{ A 'sockclientconn' object as returned by
    \code{socketClientConnection()}. }
  \item{\dots}{ further arguments passed to the method (not used for the
    moment). }
}

\value{
  \code{socketClientConnection()} creates a 'sockclientconn' object redirects
  text send to it to the SciViews socket server client. It is inherits from a
  'sockconn' object (see \code{socketConnection()}), and the only difference is
  that output is redirected to a Tcl socket corresponding to a given SciViews
  socket client currently connected.
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link[base]{socketConnection}}, \code{\link{sendSocketClients}} }

\keyword{ IO }

\concept{ stateful socket server interprocess communication }
