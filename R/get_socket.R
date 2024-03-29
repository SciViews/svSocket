#' Get the ports of current R socket servers
#'
#' Returns a list with all the ports of currently running R socket servers.
#'
#' @return
#' A character string vector, or `NULL` if no R socket server is currently
#' running.
#' @seealso [get_socket_clients()], [get_socket_server_name()], [start_socket_server]
#' @export
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
get_socket_servers <- function() {
  # Get the list of currently running socket servers
  temp_env()$socket_servers
}

# Old name of the function
#' @export
#' @rdname get_socket_servers
getSocketServers <- get_socket_servers

#' Get infos about socket clients
#'
#' List all clients currently connected to a given R socket server, or their
#' names (`sockXXX`).
#'
#' @param port the port of the R socket server.
#'
#' @return
#' [get_socket_clients()] returns a vector of character string with the address of
#' clients in the form XXX.XXX.XXX.XXX:YYY where XXX.XXX.XXX.XXX is their ip
#' address and YYY is their port. For security reasons, only localhost clients
#' (on the same machine) can connect to the socket server. Thus, XXX.XXX.XXX.XXX
#' is ALWAYS 127.0.0.1. However, the function returns the full IP address, just
#' in case of further extensions in the future. The name of these items equals
#' the corresponding Tcl socket name.
#'
#' [get_socket_clients_names()] returns only a list of the socket client names.
#'
#' @export
#' @seealso [get_socket_servers()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
get_socket_clients <- function(port = 8888) {
  if (!is.numeric(port[1]) || port[1] < 1)
    stop("'port' must be a positive integer!")
  portnum <- round(port[1])
  port <- as.character(portnum)

  # Does a server exist on this port?
  servers <- get_socket_servers()
  if (!(port %in% servers))
    return(NULL)  # If no R socket server running on this port

  # Get the list of clients currently connected to this server
  clients <- as.character(.Tcl(paste("array names Rserver", port, sep = "_")))
  # Eliminate "main", which is the connection socket
  clients <- clients[clients != "main"]

  # Are there client connected?
  if (length(clients) == 0)
    return(character(0))

  # For each client, retrieve its address and port
  addresses <- NULL
  arrayname <- paste("Rserver", port, sep = "_")
  for (i in 1:length(clients)) {
    client <- as.character(.Tcl(paste("array get", arrayname, clients[i])))
    addresses[i] <- sub(", ", ":", client[2])
  }
  names(addresses) <- clients
  addresses
}

# Old name of the function
#' @export
#' @rdname get_socket_clients
getSocketClients <- get_socket_clients

#' @export
#' @rdname get_socket_clients
get_socket_clients_names <- function(port = 8888)
  names(get_socket_clients(port = port))

# Old name of the function
#' @export
#' @rdname get_socket_clients
getSocketClientsNames <- get_socket_clients_names

#' Get the name of a R socket server
#'
#' Get the internal name given to a particular R socket server.
#'
#' @param port the port of the R socket server.
#'
#' @return
#' A string with the server name, or `NULL` if it does not exist.
#' @seealso [get_socket_servers()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
#' @export
get_socket_server_name <- function(port = 8888) {
  if (!is.numeric(port[1]) || port[1] < 1)
    stop("'port' must be a positive integer!")
  portnum <- round(port[1])
  port <- as.character(portnum)

  # Return the name of a given R socket server
  servers <- get_socket_servers()
  if (!(port %in% servers))
    return(NULL)  # If no R socket server running on this port

  server_names <- names(servers)
  server_names[servers == port]
}

# Old name of the function
#' @export
#' @rdname get_socket_clients
getSocketServerName <- get_socket_server_name
