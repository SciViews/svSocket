#' Evaluate R code in a server process
#'
#' This function is designed to connect two R processes together using the
#' socket server. It allows for piloting the server R process from a client R
#' process, to evaluate R code in the server and return its results to the
#' client.
#'
#' @param con a socket connection with the server (see examples).
#' @param expr an R expression to evaluate in the server.
#' @param send optional data to send to the server.
#'
#' @return The object returned by the last evaluation in the server.
#'
#' @details
#' The function serializes R objects using [dump()] on the server, and it
#' [source()]s the data on the client side. It has, thus, the same limitations
#' as [dump()], (see `?dump`), and in particular, environments, external
#' pointers, weak references and objects of type `S4` are not serializable with
#' [dump()] and will raise an error, or will produce unusable objects on the
#' client side. Note also that lists or attributes of accepted objects may
#' contain external pointers or environments, and thus, the whole object becomes
#' unserializable. In that case, try to coerce your object, or extract a part of
#' it on the server side to make sure you send just the part that is
#' transferable between the two R processes.
#'
#' @seealso [send_socket_clients()]
#' @author Matthew Dowle
#' @export
#' @keywords IO utilities
#' @concept stateful socket server interprocess communication
#'
#' @examples
#' \dontrun{
#' # Start an R process and make it a server
#' library(svSocket)
#' start_socket_server()
#'
#' # Start a second R process and run this code in it (the R client):
#' library(svSocket)
#'
#' # Connect with the R socket server
#' con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)
#'
#' L <- 10:20
#' L
#' eval_socket_server(con, L)             # L is not an the server, hence the error
#' eval_socket_server(con, L, L)          # Send it to the server
#' eval_socket_server(con, L)             # Now it is there
#' eval_socket_server(con, L, L + 2)
#' L
#' eval_socket_server(con, L)
#'
#' # More examples
#' eval_socket_server(con, "x <- 42")     # Set x
#' eval_socket_server(con, "y <- 10")     # Set y
#' eval_socket_server(con, x + y)         # Quotes not needed
#' eval_socket_server(con, "x + y")       # but you can put quotes if you like
#' eval_socket_server(con, x)             # Same as get x
#' eval_socket_server(con, "x + Y")       # Return server side-error to the client
#' eval_socket_server(con, x)             # Keep working after an error
#' eval_socket_server(con, "x <- 'a'")    # Embedded quotes are OK
#'
#' # Examples of sending data
#' eval_socket_server(con, X, -42)        # Alternative way to assign to X
#' eval_socket_server(con, Y, 1:10)
#' eval_socket_server(con, X + Y)
#' X  # Generates an error, X is not here in the client, only on the server
#' eval_socket_server(con, X)
#' eval_socket_server(con, "Z <- X + 3")  # Send an assignment to execute remotely
#' eval_socket_server(con, X + Z)
#' eval_socket_server(con, "Z <- X + 1:1000; NULL")   # Same but do not return Z
#' eval_socket_server(con, length(Z))
#' Z <- eval_socket_server(con, Z)        # Bring it back to client
#' Z
#'
#' # Close connection with the R socket server
#' close(con)
#'
#' # Now, switch back to the R server process and check
#' # that the created variables are there
#' L
#' x
#' y
#' X
#' Y
#' Z
#'
#' # Stop the socket server
#' stop_socket_server()
#' }
eval_socket_server <- function(con, expr, send = NULL) {
  # Evaluate expr on the R server, and return its value
  # con as returned by socketConnection(port = 8888)
  # send is optional. If supplied, expr must be a single unquoted object name.
  # Then send is evaluated on the client and the result is assigned
  # to that object on the server.
  # Robust flushing and dumping is just for windows. Linux is probably fine
  # without but no harm to leave in for now since binary mode will moot this.
  x <- substitute(expr)
  if (!missing(send) && (length(x) != 1 || mode(x) != "name"))
    stop("When send is supplied, expr must be a target variable name (unquoted) on the server to assign the result of the send expr to.")
  if (!is.character(x)) {
    x <- deparse(x)
  } else {
    x <- gsub('"', '\\\\"', x)
  }

  readLines(con)  # Flush input stream in case previous call failed to clean up
  if (missing(send)) {
    cat('..Last.value <- try(eval(parse(text = "', x,
      '"))); .f <- file(); dump("..Last.value", file = .f); flush(.f); seek(.f, 0); cat("\\n<<<startflag>>>", gsub("<pointer: [0-9a-fx]+>", "NULL", readLines(.f)), "<<<endflag>>>\\n", sep = "\\n"); close(.f); rm(.f, ..Last.value); flush.console()\n',
      file = con, sep = "")
    # It is important that one line only is written, so that other clients
    # don't mix in with these lines.
  } else {
    .f <- file()
    on.exit(close(.f))
    ..Last.value <- send
    # dump() can stop prematurely if file=con, but also good to remove the /n
    # from dump()'s output before sending (to avoid possible conflicts with
    # other clients)
    dump("..Last.value", file <- .f)
    flush(.f)
    seek(.f, 0)
    cat(readLines(.f), ';', x,
      ' <- ..Last.value; rm(..Last.value); cat("\\n<<<endflag>>>\\n"); flush.console()\n',
      file = con, sep = "")
  }
  objdump <- ""
  endloc <- NULL
  while (!length(endloc)) {
    obj <- readLines(con, n = 1000, warn = FALSE)
    # Wait for data to come back. Without this sleep, you get 20-30 calls
    # to readLines before data arrives.
    if (!length(obj)) {
      Sys.sleep(0.01)
      next
    }
    endloc <- grep("<<<endflag>>>", obj)
    if (length(endloc))
      obj <- obj[0:(endloc[length(endloc)] - 1)]
    # This is more robust than paste'ing together a potentially very
    # large single string
    objdump <- c(objdump, obj)
  }
  if (!missing(send)) {
    if (!all(objdump == "")) stop(objdump)
    return(TRUE)
  }
  startloc <- grep("<<<startflag>>>", objdump)
  if (!length(startloc))
    stop("Unable to find <<<startflag>>>")
  # The startflag is because sometimes (strangely rarely) seek, flush and dump
  # can write return value to stdout which do not source.
  objdump <- objdump[-(1:startloc[length(startloc)])]
  # Fix any output buffer wrap issues. There are line breaks mid number
  # sometimes which don't source.
  # This is why warn = FALSE appears above in the call to readLines since it
  # warns about these noncomplete lines otherwise.
  nospace <- grep("[^ ]$", objdump)
  nospace <- nospace[nospace < length(objdump)]
  for (i in rev(nospace)) {  # Robust to consecutive lines to be joined
    objdump[i] <- paste(objdump[i], objdump[i + 1], sep = "")
    objdump[i + 1] <- ""
  }
  objcon <- textConnection(objdump)
  on.exit(close(objcon))
  source(objcon, local = TRUE, echo = FALSE, verbose = FALSE)
  ..Last.value
}

# Old name of the function
#' @export
#' @rdname eval_socket_server
evalServer <- eval_socket_server
