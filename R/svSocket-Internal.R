.onLoad <- function(lib, pkg) {
  # Create our SciViews task callback manager
  #PhG: now moved to svKomodo!
  #assign_temp(".svTaskCallbackManager", svTaskCallbackManager())
}

.onUnload <- function(libpath) {
  #PhG: now moved to svKomodo!
  #removeTaskCallback("SV-taskCallbackManager")
  #rm_temp(".svTaskCallbackManager")

  #PhG: From .Last.lib(), now in .onUnload()
  # Make sure that all clients are disconnected
  # and all servers are closed
  servers <- get_socket_servers()
  if (is.null(servers) || length(servers) < 1)
    return()
  cat(ngettext(length(servers), "Stopping socket server\n",
    "Stopping socket servers\n"))
  stop_socket_server("all")
  # TODO: make sure to delete all client environments
  # (or do it in stop_socket_server()?)
}
