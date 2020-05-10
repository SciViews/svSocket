## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----install, eval=FALSE------------------------------------------------------
#  install.packages("svSocket")

## ----launch-server------------------------------------------------------------
# Start a separate R process with a script that launch a socket server on 8888
# and wait for the varible `done` in `.GlobalEnv` to finish
rscript <- Sys.which("Rscript")
system2(rscript, "--vanilla -e 'svSocket::startSocketServer(8888); while (!exists(\"done\")) Sys.sleep(1)'", wait = FALSE)

## ----wait, include=FALSE------------------------------------------------------
# Leave enough time for the server to get ready
Sys.sleep(3)

## ----connect------------------------------------------------------------------
con <- socketConnection(host = "localhost", port = 8888, blocking = FALSE)

## ----eval1--------------------------------------------------------------------
library(svSocket)
evalServer(con, '1 + 1')

## ----evalx--------------------------------------------------------------------
# Local x
x <- "local"
# x on the server
evalServer(con, 'x <- "server"')

## ----evalx2-------------------------------------------------------------------
evalServer(con, 'ls()')
evalServer(con, 'x')

## ----localx-------------------------------------------------------------------
ls()
x

## ----iris2--------------------------------------------------------------------
data(iris)
evalServer(con, iris2, iris)
evalServer(con, "ls()")         # iris2 is there
evalServer(con, "head(iris2)")   # ... and its content is OK

## ----low-level----------------------------------------------------------------
# Send a command to the R server (low-level version)
cat('{Sys.sleep(2); "Done!"}\n', file = con)
# Wait for, and get response from the server
res <- NULL
while (!length(res)) {
  Sys.sleep(0.01)
  res <- readLines(con)
}
res

## ----cat----------------------------------------------------------------------
cat(res, "\n")

## ----runServer----------------------------------------------------------------
runServer <- function(con, code) {
  cat(code, "\n", file = con)
  res <- NULL
  while (!length(res)) {
    Sys.sleep(0.01)
    res <- readLines(con)
  }
  # Use this instruction to output results as if code was run at the prompt
  #cat(res, "\n")
  invisible(res)
}

## ----runServer2---------------------------------------------------------------
(runServer(con, '{Sys.sleep(2); "Done!"}'))

## ----async--------------------------------------------------------------------
(runServer(con, '\n<<<H>>>{Sys.sleep(2); "Done!"}'))

## ----pars1--------------------------------------------------------------------
cat(runServer(con, 'ls(envir = svSocket::parSocket(<<<s>>>))'), sep = "\n")

## ----pars2--------------------------------------------------------------------
cat(runServer(con, 'svSocket::parSocket(<<<s>>>)$bare'), sep = "\n")

## ----bare-false---------------------------------------------------------------
(runServer(con, '\n<<<H>>>svSocket::parSocket(<<<s>>>, bare = FALSE)'))
(runServer(con, '1 + 1'))

## ----close--------------------------------------------------------------------
# Usually, the client does not stop the server, but it is possible here
evalServer(con, 'done <- NULL') # The server will stop after this transaction
close(con)

