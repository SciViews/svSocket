\name{evalServer}
\alias{evalServer}

\title{ Evaluate R code in a server process }
\description{
  This function is designed to connect two R processes together using the socket
  server. It allows for piloting the server R process from a client R process,
  to evaluate R code in the server and return its results to the client.
}

\usage{
evalServer(con, expr, send = NULL)
}

\arguments{
  \item{con}{ a socket connection with the server (see examples). }
  \item{expr}{ an R expression to evaluate in the server. }
  \item{send}{ optional data to send to the server. }
}

\value{
  The object returned by the last evaluation in the server.
}

\details{
  The function serializes R objects using \code{dump()} on the server, and it
  \code{source()}s the data on the client side. It has, thus, the same
  limitations as \code{dump}, (see \code{?dump}), and in particular,
  environments, external pointers, weak references and objects of type \code{S4}
  are not serializable with \code{dump()} and will raise an error, or will
  produce unusable objects on the client side. Note also that lists or
  attributes of accepted objects may contain external pointers or environments,
  and thus, the whole object becomes unserializable. In that case, try to coerce
  your object, or extract a part of it on the server side to make sure you send
  just the part that is transferable between the two R processes.
}

\author{Matthew Dowle (\email{mdowle@mdowle.plus.com})}

\seealso{ \code{\link{sendSocketClients}} }

\examples{
\dontrun{
## Start an R process and make it a server
require(svSocket)
startSocketServer()

## Start a second R process and run this code in it (the R client):
require(svSocket)

## Connect with the R socket server
con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)

L <- 10:20
L
evalServer(con, L)             # L is not an the server, hence the error
evalServer(con, L, L)          # Send it to the server
evalServer(con, L)             # Now it is there
evalServer(con, L, L + 2)
L
evalServer(con, L)

## More examples
evalServer(con, "x <- 42")     # Set x
evalServer(con, "y <- 10")     # Set y
evalServer(con, x + y)         # Don't need quotes
evalServer(con, "x + y")       # but you can put quotes if you like
evalServer(con, x)             # Same as get x
evalServer(con, "x + Y")       # Return server side-error to the client
evalServer(con, x)             # Keep working after an error
evalServer(con, "x <- 'a'")    # Embedded quotes are OK

## Examples of sending data
evalServer(con, X, -42)        # Alternative way to assign to X
evalServer(con, Y, 1:10)
evalServer(con, X + Y)
X  # Generates an error, X is not here in the client, only on the server
evalServer(con, X)
evalServer(con, "Z <- X + 3")  # Send an assignment to execute remotely
evalServer(con, X + Z)
evalServer(con, "Z <- X + 1:1000; NULL")   # Same but prevents Y being returned
evalServer(con, length(Z))
Z <- evalServer(con, Z)        # Bring it back to client
Z

## Close connection with the R socket server
close(con)

## Now, switch back to the R server process and check
## that the created variables are there
L
x
y
X
Y
Z

## Stop the socket server
stopSocketServer()
}
}

\keyword{ IO }
\keyword{ utilities }

\concept{ stateful socket server interprocess communication }
