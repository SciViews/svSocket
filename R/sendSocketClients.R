#' Send data to one or more clients through a socket
#'
#' The text is send to one or more clients of the R socket server currently
#' connected.
#'
#' @param text the text to send to the client(s).
#' @param sockets the Tcl name of the client(s) socket(s) currently connected
#' (`sockXXX`), or `"all"` (by default) to send the same text to all connected
#' clients.
#' @param serverport the port of the server considered.
#'
#' @export
#' @seealso [closeSocketClients()], [processSocket()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
#'
#' @examples
#' \dontrun{
#' # Start an R process (R#1) and make it a server
#' library(svSocket)
#' serverport <- 8888  # Port 8888 by default, but you can change it
#' startSocketServer(port = serverport)
#'
#'
#' # Start a second R process (R#2) and run this code in it (the R client):
#' library(svSocket)
#' # Connect with the R socket server
#' con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)
#'
#'
#' # Now, go back to the server R#1
#' getSocketClients() # You should have one client registered
#' # Send something to all clients from R#1
#' sendSocketClients("Hi there!")
#'
#'
#' # Switch back to client R#2
#' # Since the connection is not blocking, you have to read lines actively
#' readLines(con)
#' # Note the final empty string indicating there is no more data
#' close(con) # Once done...
#'
#'
#' # Switch to the R#1 server and close the server
#' stopSocketServer(port = serverport)
#' }
sendSocketClients <- function(text, sockets = "all", serverport = 8888) {
  # Note that 'real' clients should manage to print this BEFORE the current
  # command line, something that 'SimpleClient.Tcl' cannot do!

  # Make sure that the text ends with a carriage return
  # (same behavior as in Mac R.app but different from RGui!)
  if (regexpr("\n^", text) < 0)
      text <- paste(text, "\n", sep = "")

  # Send the given text to one or more clients through a socket
  if (sockets == "all")
    sockets <- getSocketClientsNames(port = serverport)
  if (!is.null(sockets) && length(sockets) > 0)
    for (i in 1:length(sockets))
      tcl("puts", sockets[i], text)
}
