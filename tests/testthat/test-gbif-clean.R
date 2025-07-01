test_that("clean_occ_files() works on example files", {
  skip_on_cran()
  gbif_dir <- here::here("tests/testthat/tmp/gbif-snapshot/noclean")
  expect_error(
    clean_occ_files(
      input_dir = gbif_dir, 
      output_dir = here("tests/testthat/tmp/gbif-snapshot/cleaned")
    ),
    NA
  )
  
})