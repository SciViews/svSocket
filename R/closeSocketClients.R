#' Close one or more clients currently connected
#'
#' The socket servers asks to clients to nicely disconnect (possibly doing
#' further process on their side). This function is used by
#' [stopSocketServer()], but it can also be invoked manually to ask for
#' disconnection of a particular client. Note that, in this case, the client
#' still can decide not to disconnect! The code send to ask for client
#' disconnection is: `\\f`.
#'
#' @param sockets the list of socket client names (sockXXX) to close, or `"all"`
#' (by default) to disconnect all currently connected clients.
#' @param serverport the corresponding R socket server port.
#'
#' @export
#' @seealso [sendSocketClients()]
#' @keywords IO
#' @concept stateful socket server interprocess communication
closeSocketClients <- function(sockets = "all", serverport = 8888) {
  # Nicely close socket client(s) by sending "\f"
  # To be interpreted by a compatible client that manages to close connection
  if (sockets == "all")
    sockets <- getSocketClientsNames(port = serverport)
  if (!is.null(sockets) && length(sockets) > 0)
    for (i in 1:length(sockets))
      tcl("puts", sockets[i], "\n\f")
}
