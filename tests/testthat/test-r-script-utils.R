testthat::test_that("concat_scripts() concatenates R, Rmd, and qmd files with correct formatting and relative paths", {
  # Setup: create a temporary directory and three example files
  tmp_dir <- tempdir()
  file_r <- file.path(tmp_dir, "sample1.R")
  file_rmd <- file.path(tmp_dir, "sample2.Rmd")
  file_qmd <- file.path(tmp_dir, "sample3.qmd")

  # Write simple test content
  writeLines(c("# Sample R code", "x <- 123"), file_r)
  writeLines(c("---", "title: Example", "---", "```{r}", "y <- 456", "```"), file_rmd)
  writeLines(c("```{r}", "z <- 789", "```"), file_qmd)

  # Run the function with clipboard suppressed, capturing the output
  out <- concat_scripts(
    files = c(file_r, file_rmd, file_qmd),
    outfile = NULL,
    clipboard = FALSE
  )

  # Header includes relative path containing the filename
  expect_true(any(grepl(paste0("# \\[.*", basename(file_r), "\\]"), out)))
  expect_true(any(grepl("```r", out)))
  expect_true(any(grepl(paste0("# \\[.*", basename(file_rmd), "\\]"), out)))
  expect_true(any(grepl("```\\{r\\}", out)))
  expect_true(any(grepl(paste0("# \\[.*", basename(file_qmd), "\\]"), out)))
  expect_true(any(grepl("```qmd", out)))

  # Check all script text included
  expect_true(any(grepl("x <- 123", out)))
  expect_true(any(grepl("y <- 456", out)))
  expect_true(any(grepl("z <- 789", out)))

  # Test writing output to a file (again, suppress clipboard)
  outfile <- tempfile(fileext = ".md")
  result <- concat_scripts(
    files = c(file_r, file_rmd, file_qmd),
    outfile = outfile,
    clipboard = FALSE
  )
  expect_true(file.exists(outfile))
  file_text <- readLines(outfile)
  expect_true(any(grepl("x <- 123", file_text)))
  expect_true(any(grepl(paste0("^# \\[.*", basename(file_r), "\\]"), file_text)))

  # Cleanup temporary files
  unlink(c(file_r, file_rmd, file_qmd, outfile))
})
