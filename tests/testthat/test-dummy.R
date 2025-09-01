library(testthat)

test_that("1 + 1 is equal to 2", {
  result <- 1 + 1
  expect_equal(result, 2)
})

test_that("length of letters is 26", {
  expect_equal(length(letters), 26)
})

test_that("TRUE is logically true", {
  expect_true(TRUE)
})
