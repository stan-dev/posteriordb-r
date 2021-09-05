context("test-contributing")

# This test the contribution pipeline presented in CONTRIBUTING.md.

test_that("test that all steps of the contribution pipeline works as expected", {

  expect_silent(pdbl <- pdb_local())

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

  expect_silent(write_pdb(dat, pdbl))

  ### Add model ----
  x <- list(name = "test_eight_schools_model",
            keywords = c("test_model", "hiearchical"),
            title = "Test Non-Centered Model for Eight Schools",
            description = "An hiearchical model, non-centered parametrisation.",
            urls = c("https://cran.r-project.org/web/packages/rstan/vignettes/rstan.html"),
            framework = "stan",
            references = NULL,
            added_by = "Stanislaw Ulam",
            added_date = Sys.Date())
  expect_silent(mi <- pdb_model_info(x))

  # Read in Stan model and compile the model
  file_path <- system.file("test_files/eight_schools_noncentered.stan", package = "posteriordb")
  smc <- readLines(file_path)
  sm <- rstan::stan_model(model_code = smc)
  expect_silent(mc <- model_code(sm, info = mi))

  # Write the model to the database
  expect_silent(write_pdb(mc, pdbl))

  ### Add posterior ----
  x <- list(pdb_model_code = mc,
            pdb_data = dat,
            keywords = "posterior_keywords",
            urls = "posterior_urls",
            references = "posterior_references",
            dimensions = list("dimensions" = 2, "dim" = 3),
            reference_posterior_name = NULL,
            added_date = Sys.Date(),
            added_by = "Stanislaw Ulam")
  expect_silent(po <- pdb_posterior(x, pdbl))
  expect_silent(write_pdb(po, pdbl))




  # Cleanup
  remove_pdb(dat, pdbl)
  remove_pdb(mc, pdbl)
  remove_pdb(po, pdbl)


})
