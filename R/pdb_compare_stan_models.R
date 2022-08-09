#' Compare two stan models for the same data
#'
#' @param po a `pdb_posterior` object
#' @param new_stan_model_code_file a file path to another stan code to compare with
#' @param upar_values a list of values on the constrained space to use for comparisons. Defaults to 100 samples from a standard normal.
#'
pdb_compare_stan_models <- function(po, new_stan_model_code_file, upar_values = NULL){
  checkmate::assert_class(po, "pdb_posterior")
  checkmate::assert_file_exists(new_stan_model_code_file)

  mc1 <- as.character(stan_code(po))
  mc2 <- as.character(paste(readLines(new_stan_model_code_file), collapse = "\n"))

  if(digest::sha1(mc1) == digest::sha1(mc2)) warning("The exact same model code is compared.", call. = FALSE)

  # Do hash-check and warn if the exact same code is used
  utils::capture.output(sm1 <- suppressWarnings(run_stan.pdb_posterior(po, stan_args = list(iter = 2, warmup = 0, chains = 1))))
  pdb_clear_cache()
  utils::capture.output(sm2 <- suppressWarnings(rstan::stan(file = new_stan_model_code_file, data = get_data(po), iter = 2, warmup = 0, chains = 1)))
  checkmate::assert_true(rstan::get_num_upars(sm1) == rstan::get_num_upars(sm2))
  num_upars <- rstan::get_num_upars(sm1)

  if(is.null(upar_values)){
    N <- 100
    upar_values <- lapply(rep(num_upars, N), stats::rnorm)
  }
  checkmate::assert_list(upar_values)
  for(i in seq_along(upar_values)){
    checkmate::assert_numeric(upar_values[[i]], len = num_upars)
  }

  lpd1 <- numeric(length(upar_values))
  lpd2 <- numeric(length(upar_values))

  for(i in seq_along(upar_values)){
    lpd1[i] <- rstan::log_prob(sm1, upar_values[[i]])
    lpd2[i] <- rstan::log_prob(sm2, upar_values[[i]])
  }

  if(identical(lpd2, lpd1)) {
    message("The models are identical.")
  } else {
    message("The models have different log_densities.")
  }
  return(list(upar_values = upar_values, lpd_model1 = lpd1,  lpd_model2 = lpd2))
}


