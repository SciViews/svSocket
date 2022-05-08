#' Close one or more clients currently connected
#'
#' The socket servers asks to clients to nicely disconnect (possibly doing
#' further process on their side). This function is used by
#' [stop_socket_server()], but it can also be invoked manually to ask for
#' disconnection of a particular client. Note that, in this case, the client
#' still can decide not to disconnect! The code send to ask for client
#' disconnection is: `\\f`.
#'
#' @param sockets the list of socket client names (sockXXX) to close, or `"all"`
#' (by default) to disconnect all currently connected clients.
#' @param server_port the corresponding R socket server port.
#'
#' @export
#' @seealso [send_socket_clients()]
#' @keywords IO
#' @concept stateful socket server interprocess communication
close_socket_clients <- function(sockets = "all", server_port = 8888) {
  # Nicely close socket client(s) by sending "\f"
  # To be interpreted by a compatible client that manages to close connection
  if (sockets == "all")
    sockets <- get_socket_clients_names(port = server_port)
  if (!is.null(sockets) && length(sockets) > 0)
    for (i in 1:length(sockets))
      tcl("puts", sockets[i], "\n\f")
}

# Old name of the function
#' @export
#' @rdname close_socket_clients
closeSocketClients <- close_socket_clients
