test_that("gbif_snapshot_retrieve() works on snapshot and one taxonomy record", {
  skip_on_cran()
  gbif_snapshot_path <- here::here("tests/testthat/tmp/gbif-snapshot/raw")
  
  test_lotvs_backbone_taxonomy <- readRDS(here::here("tests/testthat/tmp/test-taxonomy.rds"))
  
  gbif_dir <- here::here("tests/testthat/tmp/gbif-snapshot/noclean")
  dir.create(gbif_dir, recursive = TRUE, showWarnings = FALSE)
  expect_error(
    gbif_snapshot_retrieve(
      save_path = gbif_dir,
      gbif_snapshot_path = gbif_snapshot_path,
      taxonomy_list = test_lotvs_backbone_taxonomy
    ),
    NA
  )
})