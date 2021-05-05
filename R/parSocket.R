#' Get or set parameters specific to Sciviews socket clients
#'
#' This function manage to persistently store sensible parameters for
#' configuring communication between the server and the client, as well as, any
#' other persistent data you may need. Parameters remain set even if the client
#' disconnects and then reconnects to R, as long R was not restarted.
#'
#' @param client the client identification. By default, it is the socket
#' identifier as it appears in [[getSocketClients()]. Since no attempt is made
#' to check if the client really exists and is connected, you can create fake
#' ones, outside of the socket server, to test your code for instance.
#' @param serverport the port on which the server is running, 8888 by default.
#' Not important for fake socket client configurations.
#' @param clientsocket the Tcl name of the socket where the client is connected.
#' By default, it is the same as `client` name, but in case it was modified, do
#' provide a correct `clientsocket` string if you want to be able to activate a
#' redirection to it (see [socketClientConnection()]).
#' @param ... the parameters you want to change as named arguments. Non named
#' arguments are ignored with a warning. If you specify `arg = NULL`, the
#' corresponding variable is deleted from the environment.
#'
#' @return
#' Returns the environment where parameters and data for the client are stored.
#' To access those data, see examples below.
#'
#' @details
#' You can assign the environment to a variable, and then, access its content
#' like if it was a list (`e$var` or `e$var <- "new value"`). To get a list of
#' the content, use `ls(parSocket(client, port))`, or
#' `ls(parSocket(client, port), all.names = TRUE)`, but not
#' `names(parSocket(client, port))`. As long as you keep a variable pointing on
#' that environment alive, you have access to last values (i.e., changes done
#' elsewhere are taken into account). If you want a frozen snapshot of the
#' parameters, you should use `myvar <- as.list(parSocket(client, port)`.
#'
#' There is a convenient placeholder for code send by the client to insert
#' automatically the right socket and serverport in `parSocket()`: `<<<s>>>`.
#' Hence, code that the client send to access or change its environment is just
#' `parSocket(<<<s>>>, bare = FALSE)` or `parSocket(<<<s>>>)$bare` to set or get
#' one parameter. Note that you can set or change many parameters at once.
#'
#' Currently, parameters are:
#' - `bare = TRUE|FALSE` for "bare" mode (no prompt, no echo, no multiline; by
#' default, `bare = TRUE`),
#' - `multiline = TRUE|FALSE`: does the server accept code spread on multiple
#' lines and send in several steps (by default, yes, but works only if
#' `bare = FALSE`.
#' - `echo = TRUE|FALSE` is the command echoed to the regular R console (by
#' default `echo = FALSE`).
#' - `last = ""` string to append to each output (for instance to indicate that
#' processing is done),
#' - `prompt = "> "`, the prompt to use (if not in bare mode) and
#' - `continue = "+ "` the continuation prompt to use, when multiline mode is
#' active. You can only cancel a multiline mode by completing the R code you are
#' sending to the server, but you can break it too by sending `<<<esc>>>` before
#' the next instruction. You can indicate `<<<q>>>` or `<<<Q>>>` at the very
#' beginning of an instruction to tell R to disconnect the connection after the
#' command is processed and result is returned (with `<<<q>>>`), or when the
#' instructions are received but before they are processed (with `<<<Q>>>`).
#' This is useful for "one shot" clients (clients that connect, send code and
#' want to disconnect immediately after that). The code send by the server to
#' the client to tell him to disconnect gracefully (and do some housekeeping) is
#' `\\f` send at the beginning of one line. So, clients should detect this and
#' perform the necessary actions to gracefully disconnect from the server as
#' soon as possible, and he cannot send further instructions from this moment
#' on.
#'
#' For clients that repeatedly connect and disconnect, but want persistent data,
#' the default client identifier (the socket name) cannot be used, because that
#' socket name would change from connection to connection. The client must then
#' provide its own identifier. This is done by sending `<<<id=myID>>>` at the
#' very beginning of a command. This must be done for all commands! `myID` must
#' use only characters or digits. This code could be followed by `<<<e>>>`,
#' `<<<h>>>` or `<<<H>>>`. These commands are intended for R editors/IDE. The
#' first code `<<<e>>>` sets the server into a mode that is suitable to
#' evaluate R code (including in a multi-line way). The other code temporarily
#' configure the server to run the command (in single line mode only) in a
#' hidden way. They can be used to execute R code without displaying it in the
#' console (for instance, to start context help, to get a calltip, or a
#' completion list, etc.). The differences between `<<<h>>>` and `<<<H>>>` is
#' that the former waits for command completion and returns results of the
#' command to the client before disconnecting, while the latter disconnects from
#' the client before executing the command.
#'
#' There is a simple client (written in Tcl) available in the /etc subdirectory
#' of this package installation. Please, read the 'ReadMe.txt' file in the same
#' directory to learn how to use it. You can use this simple client to
#' experiment with the communication using these sockets, but it does not
#' provide advanced command line edition, no command history, and avoid pasting
#' more than one line of code into it.
#'
#' @export
#' @seealso [startSocketServer()], [sendSocketClients()], [getSocketClients()],
#' [socketClientConnection()]
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
#'
#' @examples
#' # We use a fake socket client configuration environment
#' e <- parSocket("fake")
#' # Look at what it contains
#' ls(e)
#' # Get one data
#' e$bare
#' # ... or
#' parSocket("fake")$bare
#'
#' # Change it
#' parSocket("fake", bare = FALSE)$bare
#' # Note it is changed too for e
#' e$bare
#'
#' # You can change it too with
#' e$bare <- TRUE
#' e$bare
#' parSocket("fake")$bare
#'
#' # Create a new entry
#' e$foo <- "test"
#' ls(e)
#' parSocket("fake")$foo
#' # Now delete it
#' parSocket("fake", foo = NULL)
#' ls(e)
#'
#' # Our fake socket config is in SciViews:TempEnv environment
#' s <- search()
#' l <- length(s)
#' pos <- (1:l)[s == "SciViews:TempEnv"]
#' ls(pos = pos)  # It is named 'SocketClient_fake'
#' # Delete it
#' rm(SocketClient_fake, pos = pos)
#' # Do some house keeping
#' rm(list = c("s", "l", "pos"))
parSocket <- function(client, serverport = 8888, clientsocket = client, ...) {
  # Set or get parameters for a given socket client
  # No attempt is made to make sure this client exists
  sc <- paste("SocketClient", client, sep = "_")
  if (!exists(sc, envir = TempEnv(), inherits = FALSE, mode = "environment")) {
    # Create a new environment with default values
    e <- new.env(parent = TempEnv())
    e$client <- client
    e$clientsocket <- clientsocket
    e$serverport <- serverport
    e$prompt <- ":> "    # Default prompt
    e$continue <- ":+ "  # Default continuation prompt
    e$code <- ""         # Current partial code for multiline mode
    e$last <- ""         # String to add at the end of evaluations
    e$echo <- FALSE      # Don't echo commands to the console
    e$flag <- FALSE      # Do not flag pieces of code (not used yet!)
    e$multiline <- TRUE  # Allow for multiline code
    e$bare <- TRUE       # Always start in "bare" mode
    # Note: in bare mode, all other parameters are inactive!
    # Assign it to SciViews:TempEnv
    assign(sc, e, envir = TempEnv())
  } else {
    e <- get(sc, envir = TempEnv(), mode = "environment")
  }
  # Change or add parameters if they are provided
  # There is no reason that serverport changes
  # but if a client disconnects and reconnects, the clientsocket may be
  # different! But only change if it is sockXXX
  if (grepl("^sock[0-9]+$", clientsocket))
    e$clientsocket <- clientsocket
  args <- list(...)
  if (l <- length(args)) {
    change.par <- function(x, val, env) {
      if (is.null(x))
        return(FALSE)  # Do nothing without a valid name
      if (is.null(val)) {
        suppressWarnings(rm(list = x, envir = env))  # Remove it
        return(TRUE)
      }
      env[[x]] <- val  # Add or change this variable in the environment
      return(TRUE)
    }
    n <- names(args)
    res <- rep(TRUE, l)
    for (i in seq_len(l))
      res[i] <- change.par(n[i], args[[i]], e)
    if (any(!res))
      warning("Non named arguments are ignored")
  }

  invisible(e)
}
