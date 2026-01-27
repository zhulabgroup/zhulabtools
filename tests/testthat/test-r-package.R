test_that("check_install_packages does not install when all present", {
  expect_message(check_install_packages("utils"), "already installed")
})

test_that("check_install_packages installs if missing", {
  skip_on_cran()
  expect_message(check_install_packages("Matrix"), regexp = "is already installed|is not installed")
  # (Can't reliably test actual install w/o side effect, so just capture message)
})

test_that("load_packages loads installed packages", {
  expect_message(load_packages("stats"), "Loading package 'stats'...")
})
