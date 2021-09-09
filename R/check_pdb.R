#' Check the content a posterior database
#'
#' @param pdb a \code{pdb} object
#' @param posterior_names_to_check an vector indicating what posteriors to check in the pdb. Default is NULL (all).
#' @param posterior_list a list of \code{pdb_posterior} objects.
#' @param run_stan_code_checks should checks using Stan be run?
#' @param verbose should check results be printed?
#' @param po a \code{pdb_posterior} object.
#'
#' @details
#' [check_pdb()] checks that the content exists as specified
#' [check_pdb_run_stan()] test to run all posteriors with stan models.
#' [check_pdb_stan_syntax()] check that all stan model code files can be parsed.
#' [check_pdb_aliases()] check that all alias are correct.
#' [check_pdb_read_model_code()] check that posteriors can be read.
#' [check_pdb_posteriors()] check a vector of posterior names.
#' [check_pdb_references()] check that all references in posteriors also exist in bibtex.
#' [check_pdb_all_models_have_posterior()] check that all models belong to a posterior
#' [check_pdb_all_data_have_posterior()] check that all datasets belong to a posterior
#' [check_pdb_all_reference_posteriors_have_posterior()] check that all reference posteriors belong to a posterior
#'
#' @return a boolean indicating if the pdb works as it should.
#'
#' @export
check_pdb <- function(pdb, posterior_names_to_check = NULL, run_stan_code_checks = FALSE, verbose = TRUE) {
  checkmate::assert_class(pdb, "pdb")
  checkmate::assert_choice(pdb_type(pdb), "local")
  checkmate::assert_subset(posterior_names_to_check, choices = posterior_names(pdb))
  checkmate::assert_flag(verbose)

  if(verbose) message("Checking posterior database...")
  if(verbose & !run_stan_code_checks) message("No checking of Stan code and syntax.")
  if(verbose & run_stan_code_checks) message("Checking that Stan can be run for posteriors.")
  return_status <- 0L

  if(!is.null(posterior_names_to_check)) {
    pns <- posterior_names_to_check
  } else {
    pns <- posterior_names(pdb)
  }

  if(verbose) message("\nChecking individual posteriors:")
  for(i in seq_along(pns)){
    if(verbose) message("- '", pns[i], "'")
    res <- try(check_pdb_posterior(pdb_posterior(x = pns[i], pdb), run_stan_code_checks = run_stan_code_checks, verbose = FALSE))
    if(inherits(res, "try-error")) return_status <- 1L
  }


  if(verbose) message("\nChecking general posterior database:")
  res <- try(check_pdb_aliases(pdb))
  if(inherits(res, "try-error")) {return_status <- 1L} else {
  if(verbose) message("- Aliases are ok.")}

  res <- try(check_pdb_all_models_have_posterior(pdb))
  if(inherits(res, "try-error")) {return_status <- 1L} else {
  if(verbose) message("- All models are part of a posterior.")}

  res <- try(check_pdb_all_data_have_posterior(pdb))
  if(inherits(res, "try-error")) {return_status <- 1L} else {
  if(verbose) message("- All data are part of a posterior.")}

  res <- try(check_pdb_all_reference_posteriors_have_posterior(pdb))
  if(inherits(res, "try-error")) {return_status <- 1L} else {
  if(verbose) message("- All reference posteriors are part of a posterior.")}

  try(check_pdb_references(pdb))
  if(inherits(res, "try-error")) {return_status <- 1L} else {
  if(verbose) message("- All bibliography elements exist in a data, model or posterior object.")}

  if(verbose & return_status == 0L) message("\nPosterior database is ok.\n")
  invisible(return_status)
}


#' @rdname check_pdb
check_pdb_read_model_code <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    model_info(pl[[i]])
    stan_code(pl[[i]])
  }
}

#' @rdname check_pdb
check_pdb_aliases <- function(pdb){
  a <- pdb_aliases("posteriors", pdb)
  checkmate::assert_character(names(a), unique = TRUE)
  pn <- unname(unlist(a))
  pdb_posterior_names <- posterior_names(pdb)
  checkmate::assert_subset(pn, pdb_posterior_names)
  checkmate::assert_true(all(!names(a) %in% pdb_posterior_names))
}

#' @rdname check_pdb
check_pdb_read_data <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    data_info(x = pl[[i]])
    sd <- stan_data(x = pl[[i]])
    pdb_cache_rm(sd, pl$pdb[[i]])
  }
}

#' @rdname check_pdb
check_pdb_read_reference_posterior_draws <- function(posterior_list){
  pl <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pl)) {
    if(is.null(pl[[i]]$reference_posterior_name)) next
    rp <- reference_posterior_draws(x = pl[[i]])
    pdb_cache_rm(rp, pl$pdb[[i]])
  }
}


#' @rdname check_pdb
check_pdb_posterior_run_stan <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  suppressWarnings(so <- utils::capture.output(run_stan(po, stan_args = list(iter = 2, warmup = 0, chains = 1))))
  so
}


check_posterior_stan_syntax <- function(po) {
  checkmate::assert_class(po, "pdb_posterior")
  suppressWarnings(sp <- rstan::stanc(model_code = stan_code(po), model_name = po$model_name))
  sp
}



#' @rdname check_pdb
check_pdb_references <- function(pdb) {
  checkmate::assert_class(pdb, "pdb")

  refs <- list()
  pns <- posterior_names(pdb)
  for (i in seq_along(pns)) {
    po <- posterior(pns[i], pdb = pdb)
    refs[[length(refs) + 1]] <- po$references
    refs[[length(refs) + 1]] <- model_info(po)$references
    refs[[length(refs) + 1]] <- data_info(po)$references
  }
  refs <- unique(unlist(refs))
  refs <- refs[nchar(refs) > 0]

  bib <- bibliography(pdb)
  bibnms <- names(bib)

  bib_in_ref <- bibnms %in% refs
  if(any(!bib_in_ref)){
    stop("Reference '", bibnms[!bib_in_ref], "'exist in bibliography but not in any posterior, data or model.", call. = FALSE)
  }
}

#' @rdname check_pdb
check_pdb_posterior_references <- function(posterior_list){
  pos <- lapply(posterior_list, checkmate::assert_class, classes = "pdb_posterior")
  for (i in seq_along(pos)) {
    bib <- pdb_bibliography(pdb = pdb(pos[[i]]))
    bibnames <- names(bib)

    porefs <- pos[[i]]$references
    ref_in_bib <- porefs %in% bibnames
    if(any(!ref_in_bib)){
      stop("Posterior reference '", porefs[!ref_in_bib], "' does not exist in the bibliography.", call. = FALSE)
    }

    mrefs <- pdb_model_info(pos[[i]])$references
    ref_in_bib <- mrefs %in% bibnames
    if(any(!ref_in_bib)){
      stop("Model reference '", mrefs[!ref_in_bib], "' does not exist in the bibliography.", call. = FALSE)
    }

    drefs <- pdb_data_info(pos[[i]])$references
    ref_in_bib <- drefs %in% bibnames
    if(any(!ref_in_bib)){
      stop("Data reference '", drefs[!ref_in_bib], "' does not exist in the bibliography.", call. = FALSE)
    }
  }
}


#' @rdname check_pdb
check_pdb_all_models_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  mnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    mnp[i] <- model_info(pl[[i]])$name
  }

  mns <- model_names(pdb)

  model_bool <- mns %in% mnp
  if(!all(model_bool)){
    stop("Model(s) " , paste0(mns[!model_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }
}

#' @rdname check_pdb
check_pdb_all_data_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  dnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    dnp[i] <- data_info(pl[[i]])$name
  }
  dns <- data_names(pdb)

  data_bool <- dns %in% dnp
  if(!all(data_bool)){
    stop("Data " , paste0(dns[!data_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }

}

#' @rdname check_pdb
check_pdb_all_reference_posteriors_have_posterior <- function(pdb){
  checkmate::assert_class(pdb, "pdb")
  pn <- posterior_names(pdb)
  rpnp <- character(length(pn))
  pl <- list()
  for (i in seq_along(pn)) {
    pl[[i]] <- posterior(pn[i], pdb = pdb)
    tc <- try(rp <- reference_posterior_draws_info(pl[[i]]), silent = TRUE)
    if(!inherits(tc, "try-error")){
      rpnp[i] <- rp$name
    }
  }

  rpns <- reference_posterior_names(pdb, "draws")

  rp_bool <- rpns %in% rpnp
  if(!all(rp_bool)){
    stop("Reference posteriors " , paste0(rpns[!rp_bool], collapse = ", "), " is missing in posteriors.", call. = FALSE)
  }
}
