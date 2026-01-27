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

  # 1. Run the function, capturing the output
  out <- concat_scripts(
    files = c(file_r, file_rmd, file_qmd),
    output_file = NULL
  )

  # -- Updated checks: Header includes relative path containing the filename
  expect_true(any(grepl(paste0("# \\[.*", basename(file_r), "\\]"), out)))
  expect_true(any(grepl("```r", out)))
  expect_true(any(grepl(paste0("# \\[.*", basename(file_rmd), "\\]"), out)))
  expect_true(any(grepl("```\\{r\\}", out)))
  expect_true(any(grepl(paste0("# \\[.*", basename(file_qmd), "\\]"), out)))
  expect_true(any(grepl("```qmd", out)))

  # 3. Check all script text included
  expect_true(any(grepl("x <- 123", out)))
  expect_true(any(grepl("y <- 456", out)))
  expect_true(any(grepl("z <- 789", out)))

  # 4. Test writing output to a file
  outfile <- tempfile(fileext = ".md")
  result <- concat_scripts(files = c(file_r, file_rmd, file_qmd), output_file = outfile)
  expect_true(file.exists(outfile))
  file_text <- readLines(outfile)
  expect_true(any(grepl("x <- 123", file_text)))
  expect_true(any(grepl(paste0("^# \\[.*", basename(file_r), "\\]"), file_text)))

  # Cleanup
  unlink(c(file_r, file_rmd, file_qmd, outfile))
})
