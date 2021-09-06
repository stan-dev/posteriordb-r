context("test-check_pdb")


test_that("test checking a posterior database", {

  expect_silent(pdb_test <- pdb_local())

  expect_message(check_pdb(pdb = pdb_test,
                           posterior_names_to_check =
                             c("eight_schools-eight_schools_centered",
                               "eight_schools-eight_schools_noncentered"),
                           run_stan_code_checks = FALSE))

})


