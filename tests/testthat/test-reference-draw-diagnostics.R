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

test_that("mean lag-1 autocorrelation is computed for every variable", {
  draws <- reference_check_draws()
  expected <- vapply(c("x", "y"), function(variable) {
    mean(vapply(draws, function(chain) {
      stats::acf(chain[[variable]], lag.max = 1, plot = FALSE)$acf[2]
    }, numeric(1)))
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
