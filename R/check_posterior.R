#' Test a posterior
#'
#' @details
#' The function checks that a posterior is consistent.
#'
#' @param po a [pdb_posterior] to check.
#' @param run_stan_code_checks should checks using Stan be run?
#' @param verbose should check results be printed?
#'
#' @export
check_pdb_posterior <- function(po, run_stan_code_checks = TRUE, verbose = TRUE) {
  checkmate::assert_class(po, "pdb_posterior")
  checkmate::assert_flag(run_stan_code_checks)
  checkmate::assert_flag(verbose)

  if(verbose) message("Checking posterior '", po$name,"' ...")

  po <- pdb_posterior(po$name, pdb = pdb(po))
  if(verbose) message("- Posterior can be read.")

  check_pdb_read_model_code(list(po))
  if(verbose) message("- The model_code can be read.")

  check_pdb_read_data(list(po))
  if(verbose) message("- The data can be read.")

  check_pdb_read_reference_posterior_draws(list(po))
  if(verbose) message("- The reference_posteriors_draws can be read (if it exists).")

  check_pdb_posterior_references(list(po))
  if(verbose) message("- The posterior references exist in the bibliography.")

  if(run_stan_code_checks){
    check_posterior_stan_syntax(po)
    if(verbose) message("- Stan syntax is ok.")

    check_pdb_posterior_run_stan(po)
    if(verbose) message("- Stan can be run for the posterior.")
  }

  if(verbose) message("\nPosterior is ok.\n")
  invisible(TRUE)
}
