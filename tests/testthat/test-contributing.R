context("test-contributing")

# This test the contribution pipeline presented in CONTRIBUTING.md.

test_that("test that all steps of the contribution pipeline works as expected", {

  expect_silent(pdb_test <- pdb_local())

  ### Add data ----
  x <- list(name = "test_eight_schools_data",
            keywords = c("test_data"),
            title = "A Test Data for the Eight Schools Model",
            description = "The data contain data from eight schools on SAT scores.",
            urls = "https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html",
            references = "testBiBTeX2020",
            added_date = Sys.Date(),
            added_by = "Stanislaw Ulam")

  # Create the data info object
  expect_silent(di <- pdb_data_info(x))

  # Access the data
  file_path <- system.file("test_files/eight_schools.R", package = "posteriordb")
  source(file_path, local = TRUE)

  # Create the data object
  expect_silent(dat <- pdb_data(eight_schools, info = di))


})
