context("test-contributing")

# This test the contribution pipeline presented in CONTRIBUTING.md.

test_that("test that all steps of the contribution pipeline works as expected", {
  assert_pdb_path_exists()
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
  expect_silent(di <- as.pdb_data_info(x))

  # Access the data
  file_path <- system.file("test_files/eight_schools.R", package = "posteriordb")
  source(file_path, local = TRUE)

  # Create the data object
  expect_silent(dat <- as.pdb_data(eight_schools, info = di))

  # remove_pdb(dat, pdbl)
  expect_silent(write_pdb(dat, pdbl, overwrite = TRUE))

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
  expect_silent(mi <- as.pdb_model_info(x))

  # Read in Stan model and compile the model
  file_path <- system.file("test_files/eight_schools_noncentered.stan", package = "posteriordb")
  smc <- readLines(file_path)
  sm <- rstan::stan_model(model_code = smc)
  expect_silent(mc <- as.model_code(sm, info = mi))

  # Write the model to the database
  # remove_pdb(mc, pdbl)
  expect_silent(write_pdb(mc, pdbl, overwrite = TRUE))

  ### Add posterior ----
  x <- list(pdb_model_code = mc,
            pdb_data = dat,
            keywords = "posterior_keywords",
            urls = "posterior_urls",
            references = "posterior_references",
            dimensions = list("theta" = 8, "mu" = 1, "tau" = 1),
            reference_posterior_name = NULL,
            added_date = Sys.Date(),
            added_by = "Stanislaw Ulam")
  expect_silent(po <- as.pdb_posterior(x, pdbl))
  # remove_pdb(po, pdbl)
  expect_silent(write_pdb(po, pdbl, overwrite = TRUE))


  ### Setup reference posterior info ----
  posteriordb:::pdb_cache_clear()

  expect_silent(po <- posterior("test_eight_schools_data-test_eight_schools_model", pdbl))

  x <- list(name = posterior_name(po),
            inference = list(method = "stan_sampling",
                             method_arguments = list(chains = 10,
                                                     iter = 20000,
                                                     warmup = 10000,
                                                     thin = 10,
                                                     seed = 4712,
                                                     control = list(adapt_delta = 0.95))),
            diagnostics = NULL, # This will be added in computing the reference posterior
            checks_made = NULL, # This will be added in computing the reference posterior
            comments = "This is a test reference posterior",
            added_by = "Stanislaw Ulam",
            added_date = Sys.Date(),
            versions = NULL # This will be added in computing the reference posterior
            )

  # Create a reference posterior draws info object
  expect_silent(rpi <- as.pdb_reference_posterior_info(x))

  expect_output(rp <- compute_reference_posterior_draws(rpi, pdbl))
  expect_silent(rp <- check_reference_posterior_draws(x = rp))

  expect_silent(write_pdb(rp, pdbl, overwrite = TRUE))

  # Cleanup
  remove_pdb(dat, pdbl)
  remove_pdb(mc, pdbl)
  remove_pdb(po, pdbl)
  remove_pdb(rp, pdbl)

})
