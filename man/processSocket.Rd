\name{processSocket}
\alias{processSocket}

\title{ The function that processes a command coming from the socket }

\description{
  This is the default R function called each time data is send by a client
  through a socket. It is possible to customize this function and to use
  customized versions for particular R socket servers.
}

\usage{
processSocket(msg, socket, serverport, ...)
}

\arguments{
  \item{msg}{ the message send by the client, to be processed. }
  \item{socket}{ the client socket identifier, as in \code{getSocketClients()}.
    This is passed by the calling function and can be used internally. }
  \item{serverport}{ the port on which the server is running, this is passed
    by the calling function and can be used internally. }
  \item{\dots}{ anything you want to pass to \code{processSocket()}, but it
    needs to rework \code{startServerSocket()} to use it). }
}

\value{
  The results of processing \code{msg} in a character string vector.
}

\note{
  There are special code that one can send to R to easily turn the server
  (possibly temporarily) into a given configuration. First, if you want to
  persistently store parameters for your client in the R server and make sure
  you retrieve the same parameters the next time you reconnect, you should
  specify your own identifier. This is done by sending \code{<<<id=myID>>>} at
  the very beginning of each of your commands. Always remember that, if you do
  not specify an identifier, the name of your socket will be used. Since socket
  names can be reused, you should always reinitialize the configuration of your
  server the first time you connect to it.

  Then, sending \code{<<<esc>>>} breaks current multiline code submission and
  flushes the multiline buffer.

  The sequence \code{<<<q>>>} at the beginning of a command indicates that the
  server wants to disconnect once the command is fully treated by R. Similarly,
  the sequence \code{<<<Q>>>} tels the server to disconnect the client before
  processing the command (no error message is returned to the client!).

  It is easy to turn the server to evaluate R code (including multiline code)
  and return the result and disconnect by using the \code{<<<e>>>} sequence at
  the beginning of a command. Using the \code{<<<h>>>} or \code{<<<H>>>}
  configure that server to process a (single-line code only) command silently
  and disconnect before (uppercase H) or after (lowercase h) processing that
  command. It is the less intrusive mode that is very useful for all commands
  that should be executed behind the sceene between R and a R editor or IDE,
  like contextual help, calltips, completion lists, etc.). Note that using
  these modes in a server that is, otherwise, configured as a multi-line server
  does not break current multi-line buffer.

  The other sequences that can be used are: \code{<<<s>>>} for a placeholder to
  configurate the current server (with configuration parameters after it), and
  \code{<<<n>>>} to indicate a newline in your code (submitting two lines of
  code as a single one; also works with servers configured as single-line
  evaluators).

  To debug the R socket server and inspect how commands send by a client are
  interpreted by this function, use \code{options(debug.Socket = TRUE)}. This
  function uses \code{Parse()} and \code{captureAll()} in order to evaluate
  R code in character string almost exactly the same way as if it was
  introduced at the command line of a R console.
}

\author{Philippe Grosjean (\email{phgrosjean@sciviews.org})}

\seealso{ \code{\link{startSocketServer}}, \code{\link{sendSocketClients}},
  \code{\link{parSocket}}, \code{\link[svMisc]{parseText}},
  \code{\link[svMisc]{captureAll}} }

\examples{
\dontrun{
## A simple REPL (R eval/process loop) using basic features of processSocket()
repl <- function ()
{
	pars <- parSocket("repl", "", bare = FALSE)  # Parameterize the loop
	cat("Enter R code, hit <CTRL-C> or <ESC> to exit\n> ")   # First prompt
	repeat {
		entry <- readLines(n = 1) 				 # Read a line of entry
		if (entry == "") entry <- "<<<esc>>>"    # Exit from multiline mode
		cat(processSocket(entry, "repl", ""))    # Process the entry
	}
}
repl()
}
}

\keyword{ IO }

\concept{ stateful socket server interprocess communication }
