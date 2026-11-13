reference_check_draws <- function(){
  set.seed(47)
  draws <- posterior::as_draws_list(array(rnorm(20000), c(2500, 4, 2),
                                         dimnames = list(NULL, NULL, c("x", "y"))))
  rpi <- as.reference_posterior_info(list(
    name = "test-reference", inference = list(method = "stan_sampling", method_arguments = list()),
    diagnostics = list(ndraws = 10000, nchains = 4,
                       effective_sample_size_bulk = c(10000, 10000),
                       effective_sample_size_tail = c(10000, 10000), r_hat = c(1, 1),
                       divergent_transitions = rep(0, 4),
                       expected_fraction_of_missing_information = rep(0.5, 4)),
    checks_made = NULL, comments = NULL, added_by = "Test", added_date = Sys.Date(),
    versions = NULL))
  as.reference_posterior_draws(draws, info = rpi)
}

test_that("abs mean lag-1 autocorrelation is computed for every variable", {
  draws <- reference_check_draws()
  expected <- vapply(c("x", "y"), function(variable) {
    mean(abs(vapply(draws, function(chain) {
      stats::acf(chain[[variable]], lag.max = 1, plot = FALSE)$acf[2]
    }, numeric(1))))
  }, numeric(1))

  for(check in list(check_reference_posterior_draws, check_summary_statistics_draws)){
    checked <- check(draws)
    expect_equal(info(checked)$diagnostics$mean_lag1_ac, unname(expected))
    expect_true(info(checked)$checks_made$abs_mean_lag1_ac_below_0_05)
  }
})

test_that("correlated and constant variables fail the lag-1 check", {
  for(check in list(check_reference_posterior_draws, check_summary_statistics_draws)){
    for(rho in c(0.8, -0.8)){
      draws <- reference_check_draws()
      for(chain in seq_along(draws)){
        draws[[chain]]$y <- as.numeric(stats::filter(draws[[chain]]$y, rho, method = "recursive"))
      }
      expect_error(check(draws), "mean_lag1_ac")
    }
    draws <- reference_check_draws()
    draws[[1]]$y[] <- 1
    expect_error(check(draws), "mean_lag1_ac")
  }
})

test_that("checked draws require the lag-1 check to have passed", {
  draws <- check_reference_posterior_draws(reference_check_draws())
  info(draws)$checks_made$abs_mean_lag1_ac_below_0_05 <- FALSE
  expect_error(assert_checked_reference_posterior_draws(draws), "mean_lag1_ac")

  draws <- check_summary_statistics_draws(reference_check_draws())
  info(draws)$checks_made$abs_mean_lag1_ac_below_0_05 <- FALSE
  expect_error(assert_checked_summary_statistics_draws(draws), "mean_lag1_ac")
})

test_that("ESS bounds are informational for reference and summary draws", {
  draws <- reference_check_draws()
  info(draws)$diagnostics$effective_sample_size_bulk[1] <- 100
  checked <- check_reference_posterior_draws(draws)
  expect_false(info(checked)$checks_made$ess_within_bounds)
  expect_silent(assert_checked_reference_posterior_draws(checked))

  draws <- reference_check_draws()
  info(draws)$diagnostics$effective_sample_size_tail[2] <- 20000
  checked <- check_summary_statistics_draws(draws)
  expect_false(info(checked)$checks_made$ess_within_bounds)
  expect_silent(assert_checked_summary_statistics_draws(checked))
  expect_silent(compute_reference_posterior_summary_statistic(checked, "mean_value"))

  info(draws)$diagnostics$r_hat[2] <- 1.1
  expect_error(check_reference_posterior_draws(draws), "r_hat")
  expect_error(check_summary_statistics_draws(draws), "r_hat")
})

test_that("ESS bounds are attached to checked draws and written to the database", {
  draws <- reference_check_draws()
  bounds <- list(ess_bulk = 10000 + c(1, -1) * 4 * sqrt(7 * 10000),
                 ess_tail = 10000 + c(1, -1) * 4 * sqrt(7 * 10000))
  for(check in list(check_reference_posterior_draws, check_summary_statistics_draws)){
    expect_equal(info(check(draws))$diagnostics$ess_bounds, bounds)
  }

  db_dir <- tempfile()
  dir.create(db_dir)
  for(directory in c("data", "models", "posteriors")) dir.create(file.path(db_dir, directory))
  db <- pdb_local(db_dir)
  info(draws)$diagnostics$effective_sample_size_bulk[1] <- 100
  checked <- check_reference_posterior_draws(draws)
  expect_silent(write_pdb(checked, db))
  written <- read_reference_posterior_info(info(checked)$name, type = "draws", pdb = db)
  expect_equal(written$diagnostics$ess_bounds, bounds)
  expect_false(written$checks_made$ess_within_bounds)
})

test_that("computed Stan diagnostics include lag-1 autocorrelation and ESS bounds", {
  testthat::local_mocked_bindings(
    get_sampler_params = function(...) rep(list(cbind(divergent__ = rep(0, 2500))), 4),
    get_bfmi = function(...) rep(0.5, 4), .package = "rstan")
  draws <- reference_check_draws()
  diagnostics <- compute_stan_sampling_diagnostics(draws, keep_dimensions = "y")
  expect_equal(diagnostics$mean_lag1_ac, compute_mean_lag1_ac(draws)[2])
  expect_equal(diagnostics$ess_bounds, ess_bounds(draws))
  expect_identical(diagnostics$diagnostic_information$names, "y")
})
