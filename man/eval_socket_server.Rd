% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eval_socket_server.R
\name{eval_socket_server}
\alias{eval_socket_server}
\alias{evalServer}
\title{Evaluate R code in a server process}
\usage{
eval_socket_server(con, expr, send = NULL)

evalServer(con, expr, send = NULL)
}
\arguments{
\item{con}{a socket connection with the server (see examples).}

\item{expr}{an R expression to evaluate in the server.}

\item{send}{optional data to send to the server.}
}
\value{
The object returned by the last evaluation in the server.
}
\description{
This function is designed to connect two R processes together using the
socket server. It allows for piloting the server R process from a client R
process, to evaluate R code in the server and return its results to the
client.
}
\details{
The function serializes R objects using \code{\link[=dump]{dump()}} on the server, and it
\code{\link[=source]{source()}}s the data on the client side. It has, thus, the same limitations
as \code{\link[=dump]{dump()}}, (see \code{?dump}), and in particular, environments, external
pointers, weak references and objects of type \code{S4} are not serializable with
\code{\link[=dump]{dump()}} and will raise an error, or will produce unusable objects on the
client side. Note also that lists or attributes of accepted objects may
contain external pointers or environments, and thus, the whole object becomes
unserializable. In that case, try to coerce your object, or extract a part of
it on the server side to make sure you send just the part that is
transferable between the two R processes.
}
\examples{
\dontrun{
# Start an R process and make it a server
library(svSocket)
start_socket_server()

# Start a second R process and run this code in it (the R client):
library(svSocket)

# Connect with the R socket server
con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)

L <- 10:20
L
eval_socket_server(con, L)             # L is not an the server, hence the error
eval_socket_server(con, L, L)          # Send it to the server
eval_socket_server(con, L)             # Now it is there
eval_socket_server(con, L, L + 2)
L
eval_socket_server(con, L)

# More examples
eval_socket_server(con, "x <- 42")     # Set x
eval_socket_server(con, "y <- 10")     # Set y
eval_socket_server(con, x + y)         # Quotes not needed
eval_socket_server(con, "x + y")       # but you can put quotes if you like
eval_socket_server(con, x)             # Same as get x
eval_socket_server(con, "x + Y")       # Return server side-error to the client
eval_socket_server(con, x)             # Keep working after an error
eval_socket_server(con, "x <- 'a'")    # Embedded quotes are OK

# Examples of sending data
eval_socket_server(con, X, -42)        # Alternative way to assign to X
eval_socket_server(con, Y, 1:10)
eval_socket_server(con, X + Y)
X  # Generates an error, X is not here in the client, only on the server
eval_socket_server(con, X)
eval_socket_server(con, "Z <- X + 3")  # Send an assignment to execute remotely
eval_socket_server(con, X + Z)
eval_socket_server(con, "Z <- X + 1:1000; NULL")   # Same but do not return Z
eval_socket_server(con, length(Z))
Z <- eval_socket_server(con, Z)        # Bring it back to client
Z

# Close connection with the R socket server
close(con)

# Now, switch back to the R server process and check
# that the created variables are there
L
x
y
X
Y
Z

# Stop the socket server
stop_socket_server()
}
}
\seealso{
\code{\link[=send_socket_clients]{send_socket_clients()}}
}
\author{
Matthew Dowle
}
\concept{stateful socket server interprocess communication}
\keyword{IO}
\keyword{utilities}
