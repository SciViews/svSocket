test_that("get_socket_servers() lists nothing upon package loading", {
  # No socket server, no clients
  expect_null(get_socket_servers())
  expect_null(get_socket_clients())
})
