test_that("create_subfolders creates and recognizes folders", {
  tempdir <- tempdir()
  folder <- "newfolder"
  on.exit(unlink(file.path(tempdir, folder), recursive = TRUE), add = TRUE)
  expect_message(create_subfolders(tempdir, folder), "Created folder")
  # Running again should mention "already exists"
  expect_message(create_subfolders(tempdir, folder), "already exists")
})

test_that("create_gitignore creates file", {
  skip_on_cran()
  tmpdir <- tempdir()
  gitignore_path <- file.path(tmpdir, ".gitignore")
  if (file.exists(gitignore_path)) file.remove(gitignore_path)
  expect_error(create_gitignore(tmpdir), NA)
  expect_true(file.exists(gitignore_path))
})

test_that("create_quarto_yaml creates file", {
  skip_on_cran()
  tmpdir <- tempdir()
  quarto_path <- file.path(tmpdir, "_quarto.yml")
  if (file.exists(quarto_path)) file.remove(quarto_path)
  expect_error(create_quarto_yaml(tmpdir), NA)
  expect_true(file.exists(quarto_path))
})
