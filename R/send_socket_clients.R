#' Send data to one or more clients through a socket
#'
#' The text is send to one or more clients of the R socket server currently
#' connected.
#'
#' @param text the text to send to the client(s).
#' @param sockets the Tcl name of the client(s) socket(s) currently connected
#' (`sockXXX`), or `"all"` (by default) to send the same text to all connected
#' clients.
#' @param server_port the port of the server considered.
#'
#' @export
#' @seealso [close_socket_clients()], [process_socket_server()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
#'
#' @examples
#' \dontrun{
#' # Start an R process (R#1) and make it a server
#' library(svSocket)
#' server_port <- 8888  # Port 8888 by default, but you can change it
#' start_socket_server(port = server_port)
#'
#'
#' # Start a second R process (R#2) and run this code in it (the R client):
#' library(svSocket)
#' # Connect with the R socket server
#' con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)
#'
#'
#' # Now, go back to the server R#1
#' get_socket_clients() # You should have one client registered
#' # Send something to all clients from R#1
#' send_socket_clients("Hi there!")
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
#' stop_socket_server(port = server_port)
#' }
send_socket_clients <- function(text, sockets = "all", server_port = 8888) {
  # Note that 'real' clients should manage to print this BEFORE the current
  # command line, something that 'SimpleClient.Tcl' cannot do!

  # Make sure that the text ends with a carriage return
  # (same behavior as in Mac R.app but different from RGui!)
  if (regexpr("\n^", text) < 0)
      text <- paste(text, "\n", sep = "")

  # Send the given text to one or more clients through a socket
  if (sockets == "all")
    sockets <- get_socket_clients_names(port = server_port)
  if (!is.null(sockets) && length(sockets) > 0)
    for (i in 1:length(sockets))
      tcl("puts", sockets[i], text)
}

# Old name of the function
#' @export
#' @rdname send_socket_clients
sendSocketClients <- send_socket_clients
