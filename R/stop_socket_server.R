#' @export
#' @rdname start_socket_server
stop_socket_server <- function(port = 8888) {
  # Stop one or more running socket server(s)
  if (port == "all") {
    port <- get_socket_servers()
    servers <- port
  } else {
    servers <- get_socket_servers()
  }
  if (!is.numeric(port) || any(port < 1))
    stop("'port' must be positive integers!")
  port <- round(port)
  any_closed <- FALSE
  for (i in 1:length(port)) {
    my_port <- port[i]
    if (my_port %in% servers) {# This port is open
      any_closed <- TRUE
      # First ask to all clients to nicely disconnect (note: if they don't
      # the server simply does not process them any more!)
      close_socket_clients(server_port = my_port)

      # Assign it back, with the corresponding port stripped out
      # But if I was the last one, delete the SocketServers variable
      servers <- servers[servers != my_port]
      if (length(servers) == 0) {
        if (exists("socket_servers", envir = temp_env(), inherits = FALSE))
          rm("socket_servers", envir = temp_env())
      } else {
        assign("socket_servers", servers[servers != my_port],
          envir = temp_env())
      }

      # Eliminate the processing function from SciViews:TempEnv
      sock_proc <- paste("socket_server_proc", my_port, sep = "_")
      if (exists(sock_proc, envir = temp_env()))
        rm(list = sock_proc, envir = temp_env())

      # Close the socket in order not to reject future client connections
      .Tcl(paste("close $Rserver_", my_port, "(main)", sep = ""))

      # Note: Tcl procs and variables are not eliminated yet
      # because there may be still clients connected!
    }
  }
  any_closed
}

# Old name of the function
#' @export
#' @rdname start_socket_server
stopSocketServer <- stop_socket_server
