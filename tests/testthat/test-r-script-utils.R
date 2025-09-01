test_that("concat_scripts_in_dir concatenates script files", {
  tmpdir <- tempdir()
  tf1 <- file.path(tmpdir, "test1.R")
  tf2 <- file.path(tmpdir, "test2.qmd")
  writeLines("x <- 1", tf1)
  writeLines("y: 2", tf2)
  expect_output(concat_scripts_in_dir(tmpdir), "test1.R")
  expect_output(concat_scripts_in_dir(tmpdir), "test2.qmd")
  # Test output_file argument:
  out <- file.path(tmpdir, "out.md")
  expect_invisible(concat_scripts_in_dir(tmpdir, output_file = out))
  expect_true(file.exists(out))
})
