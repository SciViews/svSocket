#' Start and stop a R socket server
#'
#' A R socket server is listening for command send by clients to a TCP port.
#' This server is implemented in Tcl/Tk, using the powerful 'socket' command.
#' Since it runs in the separate tcltk event loop, it is not blocking R, and it
#' runs in the background; the user can still enter commands at the R prompt
#' while one or several R socket servers are running and even, possibly,
#' processing socket clients requests.
#'
#' @param port the TCP port of the R socket server.
#' @param server_name the internal name of this server.
#' @param procfun the function to use to process client's commands. By default,
#' it is `process_socket_server()`.
#' @param secure do we start a secure (TLS) server? (not implemented yet)
#' @param local if `TRUE`, accept only connections from local clients, i.e.,
#' from clients with IP address 127.0.0.1. Set by default if the server is not
#' secure.
#'
#' @details
#' This server is currently synchronous in the processing of the command.
#' However, neither R, nor the client are blocked during exchange of data
#' (communication is asynchronous).
#'
#' Note also that socket numbers are reused, and corresponding configurations
#' are not deleted from one connection to the other. So, it is possible for a
#' client to connect/disconnect several times and continue to work with the same
#' configuration (in particular, the multiline code submitted line by line) if
#' every command starts with `<<<id=myID>>>` where `myID` is an alphanumeric
#' (unique) identifier. This property is call a stateful server. Take care! The
#' R server never checks uniqueness of this identifier. You are responsible to
#' use one that would not interfere with other, concurrent, clients connected
#' to the same server.
#'
#' For trials and basic testings of the R socket server, you can use the Tcl
#' script `SimpleClient.Tcl`. See the `ReadMe.txt` file in the
#' /etc/ subdirectory of the svSocket package folder. Also, in the source of the
#' svSocket package you will find `testCLI.R`, a script to torture test CLI for
#' R (console).
#'
#' @note
#' Due to a change in R 4.3.x in its event loop, some Tcl socket events are not
#' processes and this prevents the R socket server to work properly. This is
#' corrected in R 4.4.0. The socket server also works well with R 4.0.x, R 4.1.x
#' and R 4.2.x.
#'
#' One can write a different `procfun()` function than the default one for
#' special servers. That function must accept one argument (a string with the
#' command send by the client) and it must return a character string containing
#' the result of the computation.
#'
#' @export
#' @seealso [process_socket_server()], [send_socket_clients()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
start_socket_server <- function(port = 8888, server_name = "Rserver",
procfun = process_socket_server, secure = FALSE, local = !secure) {
  # OK, could be port = 80 to emulate a simple HTML server
  # This is the main function that starts the server
  # This function implements a basic R socket server on 'port'
  # socket_server_proc is the R workhorse function that do the computation
  # The server is written in Tcl. This way it is not blocking R command-line!
  # It is designed in a way that R can open simultaneously several ports and
  # accept connection from multiple clients to each of them.
  # Commands from each port can be processed differently

  # Secure server requires the tcl-tls package!
  if (isTRUE(secure)) {
    # TODO: On Mac with AquaTclTk installed, I need:
    # addTclPath("/System/Library/Tcl")
    res <- tclRequire("tls")
    if (!inherits(res, "tclObj"))
      stop("You must install the tcl-tls package for using a secure server!")
  }

  if (!is.function(procfun))
    stop("'procfun' must be a function!")

  # Note: the data send by the client is in the Tcl $::sock_msg variable
  # Could a clash happen here if multiple clients send data at the
  # same time to the R socket server???
  if (!is.numeric(port[1]) || port[1] < 1)
    stop("'port' must be a positive integer!")
  portnum <- round(port[1])
  port <- as.character(portnum)

  if (!is.character(server_name))
    stop("'server_name' must be a string!")
  server_name <- as.character(server_name)[1]

  # Check if the port is not open yet
  servers <- get_socket_servers()
  if (port %in% servers)
    return(TRUE)  # This port is already open!

  # We need Tcl to be able to call an R function to process clients' requests
  tclProcExists <- function(proc) {
    proc <- as.character(proc[1])
    length(as.character(tcl("info", "commands", proc))) == 1
  }

  if (!tclProcExists("socket_server_proc")) {
    # Create the callback when a client sends data
    socket_server_fun <- function() {
      # Note: I don't know how to pass arguments here.
      # So, I use Tcl global variables instead:
      # - the server port from $::sock_port,
      # - the socket client from $::sock_client,
      # - and the message from $::sock_msg
      tclGetValue_ <- function(name) {
        # Get the value stored in a plain Tcl variable
        if (!is.character(name))
          stop("'name' must be a character!")

        # Create a temporary dual variable with tclVar()
        temp <- tclVar(init = "")

        # Copy the content of the var of interest to it
        .Tcl(paste0("catch {set ", as.character(temp), " $", name, "}"))

        # Get the content of the temporary variable
        tclvalue(temp) # temp is destroyed when function exists
      }

      temp_env_ <- function() {
        pos <-  match("SciViews:TempEnv", search())
        if (is.na(pos)) {# Must create it
          `SciViews:TempEnv` <- list()
          attach_ <- function(...)
            get("attach", mode = "function")(...)
          attach_(`SciViews:TempEnv`, pos = length(search()) - 1)
          rm(`SciViews:TempEnv`)
          pos <- match("SciViews:TempEnv", search())
        }
        pos.to.env(pos)
      }

      get_temp_ <- function(x, default = NULL, mode = "any") {
        if (exists(x, envir = temp_env_(), mode = mode, inherits = FALSE)) {
          return(get(x, envir = temp_env_(), mode = mode, inherits = FALSE))
        } else {# Variable not found, return the default value
          return(default)
        }
      }

      process <- function() {
        port <- tclGetValue_("::sock_port")
        if (port == "")
          return(FALSE)  # The server is closed
        client <- tclGetValue_("::sock_client")
        if (client == "")
          return(FALSE)  # The socket client is unknown!
        msg <- tclGetValue_("::sock_msg")
        if (msg == "")
          return(FALSE)  # No message!

        # Make sure this message is not processed twice
        .Tcl("set ::sock_msg {}")

        # Do we have to debug socket transactions
        Debug <- isTRUE(getOption("debug.Socket"))
        if (Debug)
          cat(client, " > ", port, ": ", msg, "\n", sep = "")

        # Function to process the client request: socket_server_proc_<port>
        proc <- get_temp_(paste("socket_server_proc", port, sep = "_"),
          mode = "function")
        if (is.null(proc) || !is.function(proc))
          return(FALSE)  # The server should be closed
        # Call this function
        res <- proc(msg, client, port)
        # Return result to the client
        if (res != "") {
          if (isTRUE(Debug))
            cat(port, " > ", client, ": ", res, "\n", sep = "")
          chk <- try(tcl("puts", client, res), silent = TRUE)
          if (inherits(chk, "try-error")) {
            warning("Impossible to return results to a disconnected client.")
            return(FALSE)
          }
        }
        return(TRUE)  # The command is processed
      }
      return(process)  # Create the closure function for .Tcl.callback()
    }
    assign_temp("socket_server_proc", socket_server_fun())
    # Create a Tcl proc that calls this function back
    res <- .Tcl.callback(get_temp("socket_server_proc"), temp_env())
    if (length(grep("R_call ", res) > 0)) {
      # Create a proc with the same name in Tcl
      .Tcl(paste("proc socket_server_proc {} {", res, "}", sep = ""))
    } else {
      stop("Cannot create the SciViews socket server callback function")
    }
  }

  # Copy procfun into SciViews:TempEnv as socket_server_proc_<port>
  assign(paste("socket_server_proc", port, sep = "_"), procfun,
    envir = temp_env())

  # Create the Tcl function that retrieves data from the socket
  # (command send by the client), call the processing R function
  # and returns result to the client
  cmd <- paste(c(paste("proc  sock_handler_", port, " {sock} {", sep = ""),
    paste("global Rserver_", port, sep = ""),
    "if {[eof $sock] == 1 || [catch {gets $sock line}]} {",
    "    # end of file or abnormal connection drop",
    "    fileevent $sock readable {}",
    "    close $sock",
    paste("    #puts \"Close $Rserver_", port, "($sock)\"", sep = ""),
    paste("    unset Rserver_", port, "($sock)", sep = ""),
    "} else {",
    "    # Do we have to redirect the connection?",
    "    if {[string compare \">>>>>>sock\" [string range $line 0 9]] == 0} {",
    "        set redir_sock [string range $line 6 12]",
    "        fileevent $sock readable [list sock_redirect $sock $redir_sock]",
    paste("        unset Rserver_", port, "($sock)", sep = ""),
    "    } else {",
    "        global sock_port",
    "        global sock_client",
    "        global sock_msg",
    paste("        set ::sock_port", port),
    "        set ::sock_client $sock",
    "        set ::sock_msg $line",
    "        socket_server_proc    ;# process the command in R",
    "}\n}\n}"),
    collapse = "\n")
  # if {[gets $sock line] < 0} {return} # To handle incomplete lines!
  .Tcl(cmd)

  # Create the Tcl function that accepts input from a client
  # (a different one for each server port)
  # Code is slightly different if the server is only local or not
  if (isTRUE(local)) {
    cmd <- paste(c(paste("proc sock_accept_", port, " {sock addr port} {",
      sep = ""),
      paste("global Rserver_", port, sep = ""),
      "# Configure the socket",
      "fconfigure $sock -buffering line -blocking 0",
      "# Accept only local clients",
      "if {$addr != \"127.0.0.1\"} {",
      " #   puts $sock \"Error: Only local clients allowed!\"",
      "    close $sock",
      "    return",
      "}",
      paste("set Rserver_", port, "($sock) [list $addr, $port]", sep = ""),
      paste("fileevent $sock readable [list sock_handler_", port,
        " $sock]; update idletasks }", sep = "")),
    collapse = "\n")
  } else {
    cmd <- paste(c(paste("proc sock_accept_", port, " {sock addr port} {",
      sep = ""),
      paste("global Rserver_", port, sep = ""),
      "# Configure the socket",
      "fconfigure $sock -buffering line -blocking 0",
      paste("set Rserver_", port, "($sock) [list $addr, $port]", sep = ""),
      paste("fileevent $sock readable [list sock_handler_", port,
        " $sock] }", sep = "")),
    collapse = "\n")
  }
  .Tcl(cmd)

  # Create a Tcl procedure to redirect output used in socket_client_connection()
  if (!tclProcExists("sock_redirect")) {
    cmd <- paste(c("proc sock_redirect {sock tosock} {",
      "if {[eof $sock] == 1 || [catch {gets $sock line}]} {",
      "    # end of file or abnormal connection drop",
      "    fileevent $sock readable {}",
      "    close $sock",
      "} else {",
      "    puts $tosock $line",
      "}\n}"),
      collapse = "\n")
    .Tcl(cmd)
  }

  # Create the socket server itself in Tcl (a different one for each port)
  # If we want a secure server, use the tls secured socket instead
  if (isTRUE(secure)) {
    .Tcl(paste("set Rserver_", port, "(main) [tls::socket -server sock_accept_",
      #port, " -require 1 -cafile caPublic.pem -certfile ~/serverR.pem ",
      port, " -certfile Rserver.pem -keyfile Rserver.pem -ssl2 1 -ssl3 1 -tls1 0 -require 0 -request 0 ",
      port, "]; update idletasks", sep = ""))
      # For client, use:
      # set chan [tls::socket -cafile caPublic.pem -certfile ~/clientR.pem server.site.net $port]
      # To generate the keys:
      # cd ~
      # Copy /System/Library/OpenSSL/openssl.cnf on ~, and edit
      # openssl genrsa -out serverR.pem 1024   # use -des3 to secure with a password
      # openssl req -new -x509 -key serverR.pem -out clientR.pem -days 365 -config openssl.cnf
      # ... and answer to a couple of questions
  } else {
    .Tcl(paste("set Rserver_", port, "(main) [socket -server sock_accept_",
      port, " ", port, "]; update idletasks", sep = ""))
  }

  # Add this port in the variable 'Socket_servers' in SciViews:TempEnv
  socks <- get_socket_servers()
  namesocks <- names(socks)
  if (!(portnum %in% socks)) {
    socks <- c(socks, portnum)
    names(socks) <- c(namesocks, server_name)
    socks <- sort(socks)
    assign("socket_servers", socks, envir = temp_env())
  }
  return(TRUE)  # Humm! Only if it succeeds...
}

# Old name of the function
#' @export
#' @rdname start_socket_server
startSocketServer <- start_socket_server
