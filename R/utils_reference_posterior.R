#' Check that reference posterior draws follows the
#' reference posterior summary definition.
#'
#' @details For Stan sampling, the absolute mean lag-1 autocorrelation across
#' chains must be less than 0.05 for every variable. It is computed from the
#' draws and stored in \code{info(x)$diagnostics$mean_lag1_ac}.
#' ESS bounds are checked and recorded in \code{info(x)$checks_made$ess_within_bounds},
#' but a failed ESS bounds check does not disqualify the draws.
#' The bulk and tail bounds are stored in \code{info(x)$diagnostics$ess_bounds}.
#'
#' @param x a posterior name, posterior object or reference_posterior_draws object
#' @param ... currently not used.
#'
#' @export
check_summary_statistics_draws <- function(x, ...){
  UseMethod("check_summary_statistics_draws")
}

#' @rdname check_summary_statistics_draws
#' @export
check_summary_statistics_draws.character <- function(x, ...){
  x <- pdb_posterior(x, ...)
  check_summary_statistics_draws(x)
}

#' @rdname check_summary_statistics_draws
#' @export
check_summary_statistics_draws.pdb_posterior <- function(x, ...){
  x <- reference_posterior_draws(x)
  check_summary_statistics_draws(x)
}

#' @rdname check_summary_statistics_draws
#' @export
check_summary_statistics_draws.pdb_reference_posterior_draws <- function(x, ...){
  assert_reference_posterior_draws(x)
  rpi <- info(x)
  assert_reference_posterior_info(rpi)

  tst <- list()

  # Assert that there is exactly 10000 draws
  checkmate::assert_true(rpi$diagnostics$ndraws >= 10000)
  tst$ndraws_is_gte_10k <- TRUE

  if(rpi$inference$method == "stan_sampling"){
    # Assert that at least 4 chains has been used
    checkmate::assert_true(rpi$diagnostics$nchains >= 4)
    tst$nchains_is_gte_4 <- TRUE

    # Record whether ESS is within bounds, without disqualifying the draws
    ess_bnds <- ess_bounds(x)
    rpi$diagnostics$ess_bounds <- ess_bnds
    tst$ess_within_bounds <-
      checkmate::test_numeric(rpi$diagnostics$effective_sample_size_bulk, any.missing = FALSE,
                             lower = ess_bnds$ess_bulk[2], upper = ess_bnds$ess_bulk[1]) &&
      checkmate::test_numeric(rpi$diagnostics$effective_sample_size_tail, any.missing = FALSE,
                             lower = ess_bnds$ess_tail[2], upper = ess_bnds$ess_tail[1])

    # Assert all Rhat < 1.01
    checkmate::assert_numeric(rpi$diagnostics$r_hat, upper = 1.01)
    tst$r_hat_below_1_01 <- TRUE

    rpi$diagnostics$mean_lag1_ac <- compute_mean_lag1_ac(x)
    checkmate::assert_numeric(rpi$diagnostics$mean_lag1_ac, any.missing = FALSE, finite = TRUE)
    checkmate::assert_true(all(abs(rpi$diagnostics$mean_lag1_ac) < 0.05))
    tst$abs_mean_lag1_ac_below_0_05 <- TRUE

    # Assert that the EFMI is larger than 0.2
    checkmate::assert_numeric(rpi$diagnostics$expected_fraction_of_missing_information, lower = 0.2)
    tst$efmi_above_0_2 <- TRUE

  }

  # Add checks made to reference posterior
  rpi$checks_made <- tst

  # Add the rp information
  assert_reference_posterior_info(x = rpi)
  attr(x, "info") <- rpi

  # Check the reference posterior
  assert_reference_posterior_draws(x)
  assert_checked_summary_statistics_draws(x)
  invisible(x)
}


#' Check that reference posterior draws follows the
#' reference posterior draws definition.
#'
#' @details For Stan sampling, the absolute mean lag-1 autocorrelation across
#' chains must be less than 0.05 for every variable. It is computed from the
#' draws and stored in \code{info(x)$diagnostics$mean_lag1_ac}.
#' ESS bounds are checked and recorded in \code{info(x)$checks_made$ess_within_bounds},
#' but a failed ESS bounds check does not disqualify the draws.
#' The bulk and tail bounds are stored in \code{info(x)$diagnostics$ess_bounds}.
#'
#' @param x a posterior name, posterior object or reference_posterior_draws object
#' @param ... currently not used.
#'
#' @export
check_reference_posterior_draws <- function(x, ...){
  UseMethod("check_reference_posterior_draws")
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.character <- function(x, ...){
  x <- pdb_posterior(x, ...)
  check_reference_posterior_draws(x)
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.pdb_posterior <- function(x, ...){
  x <- reference_posterior_draws(x)
  check_reference_posterior_draws(x)
}

#' @rdname check_reference_posterior_draws
#' @export
check_reference_posterior_draws.pdb_reference_posterior_draws <- function(x, ...){
  assert_reference_posterior_draws(x)
  rpi <- info(x)
  assert_reference_posterior_info(rpi)

  tst <- list()

  # Assert that there is exactly 10000 draws
  checkmate::assert_true(rpi$diagnostics$ndraws == 10000)
  tst$ndraws_is_10k <- TRUE

  if(rpi$inference$method == "stan_sampling"){
    # Assert that at least 4 chains has been used
    checkmate::assert_true(rpi$diagnostics$nchains >= 4)
    tst$nchains_is_gte_4 <- TRUE

    # Record whether ESS is within bounds, without disqualifying the draws
    ess_bnds <- ess_bounds(x)
    rpi$diagnostics$ess_bounds <- ess_bnds
    tst$ess_within_bounds <-
      checkmate::test_numeric(rpi$diagnostics$effective_sample_size_bulk, any.missing = FALSE,
                             lower = ess_bnds$ess_bulk[2], upper = ess_bnds$ess_bulk[1]) &&
      checkmate::test_numeric(rpi$diagnostics$effective_sample_size_tail, any.missing = FALSE,
                             lower = ess_bnds$ess_tail[2], upper = ess_bnds$ess_tail[1])

    # Assert all Rhat < 1.01
    checkmate::assert_numeric(rpi$diagnostics$r_hat, upper = 1.01)
    tst$r_hat_below_1_01 <- TRUE

    rpi$diagnostics$mean_lag1_ac <- compute_mean_lag1_ac(x)
    checkmate::assert_numeric(rpi$diagnostics$mean_lag1_ac, any.missing = FALSE, finite = TRUE)
    checkmate::assert_true(all(abs(rpi$diagnostics$mean_lag1_ac) < 0.05))
    tst$abs_mean_lag1_ac_below_0_05 <- TRUE

    # Assert that the EFMI is larger than 0.2
    checkmate::assert_numeric(rpi$diagnostics$expected_fraction_of_missing_information, lower = 0.2)
    tst$efmi_above_0_2 <- TRUE

  }

  # Add checks made to reference posterior
  rpi$checks_made <- tst

  # Add the rp information
  assert_reference_posterior_info(x = rpi)
  attr(x, "info") <- rpi

  # Check the reference posterior
  assert_reference_posterior_draws(x)
  assert_checked_reference_posterior_draws(x)
  invisible(x)
}

compute_mean_lag1_ac <- function(x){
  posterior::summarise_draws(x, mean_lag1_ac = function(draws) {
    mean(apply(draws, 2, function(chain) {
      stats::acf(chain, lag.max = 1, plot = FALSE)$acf[2]
    }))
  })$mean_lag1_ac
}

#' Compute ESS tail and bulk bounds
#'
#' @details Compute the bounds for ESS tail and bulk based on 100 000
#' simulated ESS computations.
#'
#' @param x a [pdb_reference_posterior_draws] object.
#' @keywords internal
ess_bounds <- function(x){
  checkmate::assert_class(x, "draws")

  npar <- posterior::nvariables(x)
  ndraws <- posterior::ndraws(x)
  # We approximate ESS SD as follows (after some simulations)
  # We then use 4 SD to check the ESSs
  approx_ess_sd <- sqrt(7) * sqrt(ndraws)
  bnds <- ndraws + 4 * c(approx_ess_sd, -approx_ess_sd)

  #  alpha <- 1 - exp(log(p)/npar)
  #  essb <- esst <- NULL # To mask check NOTEs

  list(ess_bulk = bnds,
       ess_tail = bnds)

}
