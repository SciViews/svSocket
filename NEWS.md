# svSocket 1.1.0

-   All functions are renamed to use snake_case, e.g., `startSocketServer()` is renamed `start_socket_server()`. Old names remain for backward compatibility, but they are deprecated.

# svSocket 1.0.2

-   Vignette reworked. Now it does not create a socket server on R CMD check.

# svSocket 1.0.1

-   The Tcl client example in /etc now uses /usr/bin/tclsh.

-   {svHttp} package is added in suggests.

# svSocket 1.0.0

-   Code adapted to R 4.0.

-   Repository refreshed.

-   Document rewritten using **Roxygen2**.

-   Web site done with **pkgdown**.

-   Vignettes.

# svSocket 0.9-58

-   Switch to Github for development; use CI.

-   Added `importFrom()` for base packages in NAMESPACE.

-   `evalServer()` was not able to process correctly strings that contain double quotes. These are now escaped. Thanks to Adam Ryczkowski for the bug report.

# svSocket 0.9-57

-   /testCLI directory moved to /inst/testCLI.

-   An example is added that tests/demonstrates how to start, query and stop a SciViews socket server from within R.

# svSocket 0.9-56

-   Author and [Authors\@R](mailto:Authors@R){.email} fields reworked in the DESCRIPTION file.

# svSocket 0.9-55

-   `evalServer()` now can pass objects that contain pointers as attributes (e.g., 'data.table' objects), but the pointers are set to `NULL` on the client side (they are probably meaningless there). This may result in corrupted or malfunctioning objects, unless they can cope with such a situation, like 'data.table' object do.

-   Slightly reworked examples of ?evalServer and added a details section to explain which R objects cannot be transferred between R processes through evalServer().

# svSocket 0.9-54

-   An example is added to `?sendSocketClients`.

-   It now needs **svMisc** \>= 0.9-68, and it uses `SciViews:TempEnv` instead of `TempEnv` to store data from clients and servers (stateful conditions).

# svSocket 0.9-53

-   A bug in `evalServer()` leading to evaluation of a condition of length \> 1 in an `if()` construct in some case is corrected. Thanks to Xiaoqian Jiang.

# svSocket 0.9-52

-   `processSocket()` now uses the new version of `captureAll()` from **svMisc** \>= 0.9-62 with the `split=` and `echo=` arguments. Commands and results are now interwoven like in a normal console output.

-   The socket server now accepts and respond to 'HEAD' HTTP requests. It can process simple R commands in synchronous mode. This should be reserved to sense if a R server is running on a port, and which one is it (socket or http). It is also used to change config parameters like options(width = ...) in a synchronous way before running 'more serious' code asynchronously.

-   Callback mechanisms used by the server now moved to **svKomodo** package, so that it can also be used by **svHttp**.

# svSocket 0.9-51

-   `processSocket()` no longer adds en empty line at the top of R commands (bug corrected).

# svSocket 0.9-50

-   `processSocket()` now calls `parseText()` from svMisc \>= 0.9-60 instead of `Parse()`.

-   When Echo is `TRUE` and we are not in hidden mode, results are echoed directly in the R console as they are available, and not any more at the end of the calculation.

-   A new type of connection is added: a 'sockclientconn' that allows to redirect output (append or write-only, for the moment) to a SciViews socket client. It is created by using `socketClientConnection()` and has a specific `summary()` method. It inherits from a 'sockconn' object and should behave similarly.

-   `parSocket()` has a new argument, `clientsocket=`, that allows to pass the Tcl name of the client's socket. This is required to use `socketClientConnection()` by providing only the client's name (and thus, the required Tcl socket name is obtained through the property `parSocket(....)$clientsocket`, if it was previously recorded). The default process function, `processSocket()` is changed to record the Tcl socket in `parSocket()` each time a client connects to the server and sends its first command through it.

# svSocket 0.9-49

-   Small change in `startSocketServer()`: the Tcl/Tk callback function now calls a closure located in `SciViews:TempEnv` (`SocketServerProc`).

# svSocket 0.9-48

-   `svTaskCallbackManager()` added to allow callbacks to be executed after each (complete) R code send by a client to the server, as well as, any top-level task run at the R console.

# svSocket 0.9-47

-   The server now calls `taskCallbacks` on non-hidden mode after code evaluation.

# svSocket 0.9-46

-   `evalServer()` slightly reworked.

-   `sendSocketServer()` eliminated (superseded by `evalServer()`).

# svSocket 0.9-45

-   Bug correction in `evalServer()`.

# svSocket 0.9-44

-   Added function `evalServer()` for R interprocess communication using this R socket server mechanism.

# svSocket 0.9-43

-   Example added in `processSocket()`, implementing a simple REPL.

-   A new function, `sendSocketServer()` is added to send and evaluate commands from one R instance (client) to another one (a R socket server).

# svSocket 0.9-43

-   Polishing package for CRAN submission.

# svSocket 0.9-42

-   Made compatible with R 2.6.x (previous package was R \>= 2.7.0).

# svSocket 0.9-41

-   Correction in `startSocketServer()`: the `SocketServerProc` function was not protected against garbage collection. Consequently, the socket server stopped working at unpredictable events.

-   Correction of a bug preventing `processSocket()` to display error messages. Instead, I got: `Error in ngettext(1, "Error: ", domain = "R") : argument "msg2" is missing, with no default`.

# svSocket 0.9-40

-   This is the first version distributed on R-forge. It is completely refactored from older versions (on CRAN since 2003) to make it run with SciViews-K and Komodo Edit (Tinn-R is also supported, but not SciViews-R Console any more).
