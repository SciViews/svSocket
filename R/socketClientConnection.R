#' Open a connection to a SciViews socket client for write access
#'
#' A 'sockclientconn' object is created that opens a connection from R to a
#' SciViews socket client (that must be currently connected).
#'
#' @param client the client identification. By default, it is the socket
#' identifier as it appears in [getSocketClients()]. The client must be
#' currently connected.
#' @param serverport the port on which the server is running, 8888 by default.
#' This server must be currently running.
#' @param socket the Tcl socket name where the targeted client is connected. If
#' not provided, it will be guessed from `client`, otherwise, `client` is
#' ignored.
#' @param blocking logical. Should the connection wait that the data is written
#' before exiting?
#' @param open character. How the connection is opened. Currently, only `"a"`
#' for append (default) or `"w"` for write access are usable.
#' @param encoding the name of the encoding to use.
#' @param object A 'sockclientconn' object as returned by
#' [socketClientConnection()].
#' @param ... further arguments passed to the method (not used for the moment).
#'
#' @return
#' [socketClientConnection()] creates a 'sockclientconn' object redirects text
#' send to it to the SciViews socket server client. It is inherits from a
#' 'sockconn' object (see `socketConnection()`), and the only difference is that
#' output is redirected to a Tcl socket corresponding to a given SciViews socket
#' client currently connected.
#' @export
#' @seealso [socketConnection()], [sendSocketClients()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
socketClientConnection <- function(client, serverport = 8888, socket,
blocking = FALSE, open = "a", encoding = getOption("encoding")) {
  # Only accepts "a" or "w" modes currently
  if (!open %in% c("a", "w"))
    stop("Only modes \"a\" or \"w\" are currently supported")

  # Connect to a client of the svSocket server, serving on 'serverport'
  # First check that the server is running and is serving 'socket'
  if (is.null(serverport) || !is.numeric(serverport[1]) || serverport[1] < 1)
    stop("'serverport' must be a positive integer!")
  portnum <- round(serverport[1])
  if (!portnum %in% getSocketServers())
    stop("There is no currently running socket server on port ",
      portnum, "\n    Start one by using startSocketServer() first")
  # If socket is not provided, try to get it from client's infos
  if (missing(socket))
    socket <- parSocket(client, serverport)$clientsocket
  # Check that 'socket' is a currently opened Tcl socket and is a client
  res <- try(.Tcl(paste("fconfigure", socket, "-peername")), silent = TRUE)
  if (inherits(res, "try-error"))
    stop("This client or this socket is not currently connected")
  res <- as.character(res)
  redir <- paste("->", res[1], ":", res[length(res)], sep = "")
  # That's OK, we could proceed in opening a socketConnection and redirect it
  # to the client's socket...
#  currSocks <- getSocketClientsNames(portnum)
  sck <- socketConnection(host = "127.0.0.1", port = portnum, server = FALSE,
    blocking = blocking, open = open, encoding = encoding)
  # We need to leave enough time in the background to Tcl to establish the
  # connection
#  i <- 0
#  mySock <- character(0)
#  while (length(mySock) < 1 && i < 10) {
#    i <- i + 1
    .Tcl("update idletasks")
#    Sys.sleep(0.05)
#    currSocks2 <- getSocketClientsNames(portnum)
#    mySock <- currSocks2[!currSocks2 %in% currSocks]
#  }
#  if (length(mySock) < 1) {
#    try(close(sck), silent = TRUE)
#    stop("Unable to connect to the client socket")
#  }
#  mySock <- mySock[1]  # Just a precaution
  # Now, activate the redirection in Tcl
#  .Tcl(paste("fileevent", mySock, "readable [list sockRedirect", mySock,
#    socket, "]"))
  # ... and eliminate this client for the list
#  .Tcl(paste("unset Rserver_", portnum, "(", mySock, ")", sep = ""))

  # Instruct the socket server to redirect to socket
  cat(">>>>>>", socket, "\n", sep = "", file = sck)
  .Tcl("update idletasks")

  # Finalize the "sockclientconn" object
#  attr(sck, "conn_tclsocket") <- mySock
  attr(sck, "conn_redirsocket") <- socket
  attr(sck, "conn_redirection") <- redir
  class(sck) <- c("sockclientconn", class(sck))
  sck
}

#' @export
#' @rdname socketClientConnection
#' @method summary sockclientconn
summary.sockclientconn <- function(object, ...) {
  obj2 <- object
  class(obj2) <- "connection"
  res <- summary(obj2)
  # Change description and class
  res$description <- attr(object, "conn_redirection")
  res$class <- "sockclientconn"
  res
}
