#' @details
#' The SciViews \{svSocket\} package provides a stateful, multi-client and
#' preemptive socket server. Socket transaction are operational even when R is
#' busy in its main event loop (calculation done at the prompt). This R socket
#' server uses the excellent asynchronous socket ports management by Tcl, and
#' thus, it needs a working version of Tcl/Tk (>= 8.4) and of the \{tcltk\} R
#' package.
#'
#' A particular effort has been made to handle requests the same way as if they
#' where introduced at the command prompt, including presentation of the output.
#' However, the server sends results back to the client only at the end of the
#' computations. It means that any interaction during computation (for instance,
#' using [scan()], [browser()], or `par(ask = TRUE)` is not echoed in the client
#' on due time. If you parameterize the socket server to echo commands in the R
#' console, such interaction would be possible from there. Another option is to
#' run R in non-interactive mode.
#'
#' Although initially designed to server GUI clients, the R socket server can
#' also be used to exchange data between separate R processes. The
#' [eval_socket_server()] function is particularly useful for this. Note,
#' however, that R objects are serialized into a text (i.e., using [dump()])
#' format, currently. It means that the transfer of large object is not as
#' efficient as, say \{Rserver\} (\{Rserver\} exchanges R objects in binary format,
#' but \{Rserver\} is not stateful, clients do not share the same global workspace
#' and it does not allow concurrent use of the command prompt).
#'
#' Due to a change in R 4.3.x in its event loop, some Tcl socket events are not
#' processes and this prevents the R socket server to work properly. This is
#' corrected in R 4.4.0. The socket server also works well with R 4.0.x, R 4.1.x
#' and R 4.2.x.
#'
#' See [start_socket_server()] and [process_socket_server()] for further
#' implementation details.
#' @keywords internal
"_PACKAGE"

#' @importFrom tcltk tcl .Tcl tclRequire tclVar tclvalue .Tcl.callback
#' @importFrom svMisc capture_all parse_text temp_env get_temp assign_temp rm_temp
#' @importFrom utils URLdecode
# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
