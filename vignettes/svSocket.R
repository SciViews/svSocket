## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----install, eval=FALSE------------------------------------------------------
#  install.packages("svSocket")

## ----launch-server, eval=FALSE------------------------------------------------
#  # Start a separate R process with a script that launch a socket server on 8889
#  # and wait for the variable `done` in `.GlobalEnv` to finish
#  rscript <- Sys.which("Rscript")
#  system2(rscript, "--vanilla -e 'svSocket::start_socket_server(8889); while (!exists(\"done\")) Sys.sleep(1)'", wait = FALSE)

## ----no_server_version, include=FALSE-----------------------------------------
server_ready <- FALSE

## ----wait, include=FALSE, eval=FALSE------------------------------------------
#  # Launch the server
#  rscript <- Sys.which("Rscript")
#  try(system2(rscript, "--vanilla -e 'svSocket::start_socket_server(8889); while (!exists(\"done\")) Sys.sleep(1)'", wait = FALSE), silent = TRUE)
#  
#  # Leave enough time for the server to get ready
#  Sys.sleep(5)
#  # and make sure we can connect to it
#  con <- try(socketConnection(host = "localhost", port = 8889,
#      blocking = FALSE, timeout = 30),
#    silent = TRUE)
#  server_ready <- !inherits(con, "try-error")

## ----connect, eval=FALSE------------------------------------------------------
#  con <- socketConnection(host = "localhost", port = 8889,
#    blocking = FALSE, timeout = 30)

## ----eval1, eval=server_ready-------------------------------------------------
#  library(svSocket)
#  eval_socket_server(con, '1 + 1')

## ----evalx, eval=server_ready-------------------------------------------------
#  # Local x
#  x <- "local"
#  # x on the server
#  eval_socket_server(con, 'x <- "server"')

## ----evalx2, eval=server_ready------------------------------------------------
#  eval_socket_server(con, 'ls()')
#  eval_socket_server(con, 'x')

## ----localx, eval=server_ready------------------------------------------------
#  ls()
#  x

## ----iris2, eval=server_ready-------------------------------------------------
#  data(iris)
#  eval_socket_server(con, iris2, iris)
#  eval_socket_server(con, "ls()")          # iris2 is there
#  eval_socket_server(con, "head(iris2)") # ... and its content is OK

## ----low-level, eval=server_ready---------------------------------------------
#  # Send a command to the R server (low-level version)
#  cat('{Sys.sleep(2); "Done!"}\n', file = con)
#  # Wait for, and get response from the server
#  res <- NULL
#  while (!length(res)) {
#    Sys.sleep(0.01)
#    res <- readLines(con)
#  }
#  res

## ----cat, eval=server_ready---------------------------------------------------
#  cat(res, "\n")

## ----runServer, eval=server_ready---------------------------------------------
#  run_socket_server <- function(con, code) {
#    cat(code, "\n", file = con)
#    res <- NULL
#    while (!length(res)) {
#      Sys.sleep(0.01)
#      res <- readLines(con)
#    }
#    # Use this instruction to output results as if code was run at the prompt
#    #cat(res, "\n")
#    invisible(res)
#  }

## ----runServer2, eval=server_ready--------------------------------------------
#  (run_socket_server(con, '{Sys.sleep(2); "Done!"}'))

## ----async, eval=server_ready-------------------------------------------------
#  (run_socket_server(con, '\n<<<H>>>{Sys.sleep(2); "Done!"}'))

## ----pars1, eval=server_ready-------------------------------------------------
#  cat(run_socket_server(con, 'ls(envir = svSocket::par_socket_server(<<<s>>>))'), sep = "\n")

## ----pars2, eval=server_ready-------------------------------------------------
#  cat(run_socket_server(con, 'svSocket::par_socket_server(<<<s>>>)$bare'), sep = "\n")

## ----bare-false, eval=server_ready--------------------------------------------
#  (run_socket_server(con, '\n<<<H>>>svSocket::par_socket_server(<<<s>>>, bare = FALSE)'))
#  (run_socket_server(con, '1 + 1'))

## ----close, eval=server_ready-------------------------------------------------
#  # Usually, the client does not stop the server, but it is possible here
#  eval_socket_server(con, 'done <- NULL') # The server will stop after this transaction
#  close(con)

